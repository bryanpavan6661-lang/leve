# Permite usar os scripts de build sem copiá-los para a imagem final
FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files

# Imagem base: Fedora bootc 44
# - mínima (sem desktop), kernel padrão do Fedora (assinado, funciona com Secure Boot)
# - mantém a base x86-64 clássica, então roda em CPUs mais antigas
#   (o CentOS Stream 10 exige CPUs mais novas, por isso não foi usado)
FROM quay.io/fedora/fedora-bootc:44

### MODIFICAÇÕES
## Tudo que é instalado/configurado fica em build_files/build.sh
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### LINT: verifica se a imagem final está correta
RUN bootc container lint
