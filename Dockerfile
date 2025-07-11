FROM netboxcommunity/netbox:latest

USER root

# Install required system packages
RUN apt-get update && apt-get install -y \
    git \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# --- Install Device Type Library Import (DTLI) ---
RUN git clone https://github.com/netbox-community/Device-Type-Library-Import.git /opt/dtli

RUN python3 -m venv /opt/dtli/venv && \
    /opt/dtli/venv/bin/pip install --upgrade pip && \
    /opt/dtli/venv/bin/pip install -r /opt/dtli/requirements.txt

RUN git clone https://github.com/netboxlabs/diode-netbox-plugin.git /opt/diode-netbox-plugin && \
    . /opt/netbox/venv/bin/activate && \
    /opt/netbox/venv/bin/pip install /opt/diode-netbox-plugin


# --- Apply NetBox migrations and collect static assets ---
WORKDIR /opt/netbox/netbox
RUN /opt/netbox/venv/bin/python manage.py migrate && \
    /opt/netbox/venv/bin/python manage.py collectstatic --no-input

USER netbox
