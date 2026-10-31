# Leve

Sistema Linux leve para PCs e notebooks: **Fedora bootc 44 + XFCE**, com firmware completo, zram, TLP (bateria), earlyoom e boot enxuto. Atualizações atômicas: se uma atualização der problema, o sistema volta para a versão anterior.

## Como usar

1. No GitHub, crie um repositório **chamado `leve`** a partir deste conteúdo (o nome precisa ser igual ao `IMAGE_NAME` do arquivo `image-template.env`).
2. O usuário do GitHub (`bryanpavan6661-lang`) já está configurado em `image-template.env` e `disk_config/iso.toml`.
3. Em *Settings → Actions → General → Workflow permissions*, marque **Read and write permissions**.
4. Faça o commit. A aba *Actions* roda **Build container image** (leva alguns minutos).
5. Em *Packages* do seu perfil, abra o pacote `leve` e deixe a visibilidade **Public** (necessário para o ISO e para atualizar o sistema instalado).
6. Em *Actions → Build disk images → Run workflow* (plataforma `amd64`) gere o **ISO**. Baixe-o nos *Artifacts*.
7. Grave o ISO num pendrive (Rufus ou balenaEtcher) e instale.

## Onde mexer

| Quero... | Arquivo |
|---|---|
| Instalar/remover programas | `build_files/build.sh` |
| Ligar suporte a impressoras | `ENABLE_PRINTING=true` no `build.sh` |
| Ajustar memória, logs, boot | `system_files/` |
| Mudar parâmetros do kernel | `system_files/usr/lib/bootc/kargs.d/10-leve.toml` |

## Depois de instalar

Para instalar apps pelo Flatpak:

```
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

Se a tela ficar preta em algum hardware muito antigo, no menu do GRUB pressione `e` e adicione `nomodeset` ao final da linha que começa com `linux`.
