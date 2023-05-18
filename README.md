# LazyCommit

Gerador de mensagens de Commit para preguiçosos, com markdown e preview

## Instruções para instalação

```console
sudo wget https://raw.githubusercontent.com/rilder-almeida/LazyCommit/master/install_lazycommit.sh && sh install_lazycommit.sh && rm -rf install_lazycommit.sh
```

## Uso

```console

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

	-h, --help            Ajuda para o lazycommit (esta tela)
			
```