FROM netboxcommunity/netbox:latest

USER root

# --- Install system packages ---
RUN apt-get update && apt-get install -y \
    git \
    python3-pip \
    python3-venv \
    libsasl2-dev \
    libldap2-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# --- Install DTLI in its own venv ---
RUN git clone https://github.com/netbox-community/Device-Type-Library-Import.git /opt/dtli

RUN python3 -m venv /opt/dtli/venv && \
    /opt/dtli/venv/bin/pip install --upgrade pip && \
    /opt/dtli/venv/bin/pip install -r /opt/dtli/requirements.txt

# --- Prepare NetBox plugin install ---
# Copy local plugin requirements and install them into NetBox venv
COPY ./plugin_requirements.txt /opt/netbox/

# Optional: if using offline cache, copy vendor dir and install from there
# COPY ./plugins_offline /opt/netbox/plugins_offline/
# RUN /usr/local/bin/uv pip install  --no-index --find-links=/opt/netbox/plugins_offline -r /opt/netbox/plugin_requirements.txt

# Default online method
RUN /usr/local/bin/uv pip install -r /opt/netbox/plugin_requirements.txt


