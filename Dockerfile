# ─────────────────────────────────────────────────────────────────
#  DevForge — Alpine-based container runner
#  Provides a reproducible shell environment with DevForge pre-loaded
# ─────────────────────────────────────────────────────────────────
FROM alpine:3.20 AS base

RUN apk add --no-cache \
      bash \
      curl \
      git \
      jq \
      coreutils \
      grep \
      sed \
      gawk \
      findutils \
      ca-certificates \
    && rm -rf /var/cache/apk/*

# ── Create non-root devforge user ─────────────────────────────────
RUN addgroup --system --gid 1001 devforge \
 && adduser  --system --uid 1001 --ingroup devforge --shell /bin/bash devforge

WORKDIR /devforge

# ── Copy project files ────────────────────────────────────────────
COPY --chown=devforge:devforge install.sh   ./install.sh
COPY --chown=devforge:devforge lib/         ./lib/
COPY --chown=devforge:devforge modules/     ./modules/
COPY --chown=devforge:devforge config/      ./config/

RUN chmod +x install.sh \
 && find modules/ -name "*.sh" -exec chmod +x {} \; \
 && find lib/     -name "*.sh" -exec chmod +x {} \;

# ── Smoke-test: load libs without running install ─────────────────
RUN bash -n install.sh \
 && for f in lib/*.sh; do bash -n "$f"; done \
 && for f in modules/*.sh; do bash -n "$f"; done

USER devforge

ENV DEVFORGE_LANG=en \
    DEVFORGE_DRY_RUN=true

LABEL org.opencontainers.image.title="DevForge" \
      org.opencontainers.image.description="Developer environment forge — macOS & Linux automated setup" \
      org.opencontainers.image.source="https://github.com/klosraf/devforge" \
      org.opencontainers.image.url="https://github.com/klosraf/devforge" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.vendor="klosraf"

ENTRYPOINT ["/bin/bash", "install.sh"]
CMD ["--help"]
