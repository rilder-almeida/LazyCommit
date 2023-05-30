package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/charmbracelet/glamour"
	"github.com/spf13/cobra"
)

var version = "v.0.07b"

var (
	_typeArg    string
	titleArg    string
	problemArg  string
	solutionArg string
	linksArg    []string
	yesFlag     bool
	skipCIFlag  bool
	wipFlag     bool
	versionFlag bool
)

func checkLatestRelease() error {
	curlResult, err := exec.Command("curl", "-s", "https://api.github.com/repos/rilder-almeida/LazyCommit/releases/latest").Output()
	if err != nil {
		return errors.New("Failed to check latest release: " + err.Error())
	}

	var release struct {
		Tag string `json:"tag_name"`
	}
	err = json.Unmarshal(curlResult, &release)
	if err != nil {
		return errors.New("Failed to check latest release: " + err.Error())
	}

	if strings.TrimSpace(release.Tag) != strings.TrimSpace(version) {
		fmt.Println("Nova versão disponível: " + release.Tag)
		fmt.Println("Execute o comando para atualizar:")
		fmt.Println("curl -s https://raw.githubusercontent.com/rilder-almeida/LazyCommit/master/install.sh | bash")
		return nil
	}

	return nil

}

func cleanup() error {
	if _, err := os.Stat(os.Getenv("HOME") + "/.gitmessage"); os.IsNotExist(err) {
		return nil
	}

	err := os.Remove(os.Getenv("HOME") + "/.gitmessage")

	if err != nil {
		return errors.New("Failed to delete .gitmessage file: " + err.Error())
	}
	return nil
}

func makeMessage(args []string) string {
	message := ""

	if strings.TrimSpace(_typeArg) != "" {
		message += "[" + _typeArg + "] "
	}

	if strings.TrimSpace(titleArg) != "" {
		message += titleArg
	}

	if strings.TrimSpace(problemArg) != "" {
		message += "\n\nProblema:\n\n" + problemArg
	}

	if strings.TrimSpace(solutionArg) != "" {
		message += "\n\nSolução:\n\n" + solutionArg
	}

	if len(linksArg) > 0 {
		message += "\n\nLinks:"
		for _, link := range linksArg {
			message += "\n\n - " + link
		}
	}

	if wipFlag {
		message = "[wip] " + message
	}

	if skipCIFlag {
		message = "[skip-ci] " + message
	}

	return message
}

func getFile() (*os.File, error) {
	err := cleanup()
	if err != nil {
		return nil, err
	}

	file, err := os.Create(os.Getenv("HOME") + "/.gitmessage")
	if err != nil {
		return nil, errors.New("Failed to create .gitmessage file: " + err.Error())
	}
	return file, nil
}

func writeFile(file *os.File, message string) error {
	_, err := file.WriteString(message)
	if err != nil {
		return errors.New("Failed to write to .gitmessage file: " + err.Error())
	}
	return nil
}

func makePreview(message string) error {
	r, err := glamour.NewTermRenderer(glamour.WithAutoStyle())
	if err != nil {
		return errors.New("Failed to create markdown renderer: " + err.Error())
	}

	out, err := r.Render(message)
	if err != nil {
		return errors.New("Failed to render preview: " + err.Error())
	}

	fmt.Println("\nCommit Preview:\n", out)
	return nil
}

func makeCommit() error {
	commitCmd := exec.Command("git", "commit", "-F", os.Getenv("HOME")+"/.gitmessage")
	commitCmd.Stdout = os.Stdout
	commitCmd.Stderr = os.Stderr
	err := commitCmd.Run()
	if err != nil {
		return errors.New("Failed to commit: " + err.Error())
	}
	fmt.Println("\nMessage committed successfully!")
	return cleanup()
}

func getRunCmd(cmd *cobra.Command, args []string) error {
	if versionFlag {
		fmt.Println("lazycommit " + version)
		return nil
	}

	message := makeMessage(args)

	if message == "" {
		fmt.Println(cmd.Use)
		return nil
	}

	file, err := getFile()
	defer func() { file.Close() }()
	if err != nil {
		return err
	}

	err = writeFile(file, message)
	if err != nil {
		return err
	}
	file.Close()

	if yesFlag {
		return makeCommit()
	}

	err = makePreview(message)
	if err != nil {
		return err
	}

	var confirm string
	fmt.Print("\nDo you want to commit the message? (y/N) ")
	fmt.Scanln(&confirm)
	fmt.Println()
	if strings.ToLower(confirm) == "y" {
		return makeCommit()
	}

	fmt.Println("\nMessage not committed.")
	return cleanup()
}

func main() {
	rootCmd := &cobra.Command{
		RunE:         getRunCmd,
		SilenceUsage: true,
	}

	rootCmd.Flags().StringVarP(&_typeArg, "type", "t", "", "Tipo do commit")
	rootCmd.Flags().StringVarP(&titleArg, "title", "i", "", "Título do commit")
	rootCmd.Flags().StringVarP(&problemArg, "problem", "p", "", "Descrição do problema")
	rootCmd.Flags().StringVarP(&solutionArg, "solution", "s", "", "Descrição da solução")
	rootCmd.Flags().StringArrayVarP(&linksArg, "links", "l", []string{}, "Links relacionados")
	rootCmd.Flags().BoolVarP(&yesFlag, "yes", "y", false, "Commita sem preview")
	rootCmd.Flags().BoolVar(&skipCIFlag, "skip-ci", false, "Skip CI")
	rootCmd.Flags().BoolVar(&wipFlag, "wip", false, "Work in progress")
	rootCmd.Flags().BoolVarP(&versionFlag, "version", "v", false, "Versão do lazycommit")

	rootCmd.Use = `
lazycommit - Gerador de mensagens de Commit para preguiçosos, com markdown e preview

Uso:
	lazycommit [flags]

Exemplo:

	lazycommit -t feat -i "Adiciona funcionalidade X" -p "O problema era Y" -s "A solução foi Z" -l "https://link1.com" -l "https://link2.com" -y --skip-ci --wip

Flags:

	-t, --type string     Tipo do commit
	-i, --title string    Título do commit
	-p, --problem string  Descrição do problema
	-s, --solution string Descrição da solução
	-l, --links string    Links relacionados

	-y, --yes             Commita sem confirmação

	--skip-ci             Adiciona [skip-ci] no início da mensagem
	--wip                 Adiciona [wip] no início da mensagem

	-v, --version         Versão do lazycommit
	-h, --help            Ajuda para o lazycommit (esta tela)
`

	rootCmd.SetHelpFunc(func(cmd *cobra.Command, args []string) {
		fmt.Println(cmd.Use)
	})

	rootCmd.SetUsageFunc(func(cmd *cobra.Command) error {
		fmt.Println(cmd.Use)
		return nil
	})

	rootCmd.SetFlagErrorFunc(func(cmd *cobra.Command, err error) error {
		fmt.Println(cmd.Use)
		return nil
	})

	err := checkLatestRelease()
	if err != nil {
		fmt.Println(err)
	}

	if err := rootCmd.Execute(); err != nil {
		os.Exit(1)
	}
}
