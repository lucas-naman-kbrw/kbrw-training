#!/bin/bash

set -e

if [ "$#" -ne 2 ]; then

  echo "Usage : confvpn.sh login password"

  exit 1

fi

if [ "$(id -u)" != "0" ]; then

  echo "This script must be run as root : please sudo"

  exit 1

fi

function echogreen {

  GREEN='\033[1;32m'; NC='\033[0m'

  printf "${GREEN}$1${NC}\n"

}

echogreen "Exec apt-get install strongswan-starter strongswan-ikev2 libstrongswan-extra-plugins"

apt-get install strongswan-starter strongswan-ikev2 libstrongswan-extra-plugins

sed -i '/# START KBRWCONF/,/# END KBRWCONF/d' /etc/ipsec.conf

echogreen "Did remove old ipsec configuration in ipsec.conf"

sed -i '/# START KBRWCONF/,/# END KBRWCONF/d' /etc/ipsec.secrets

echogreen "Did remove old ipsec configuration in ipsec.secrets"

cat >> /etc/ipsec.conf <<EOF

# START KBRWCONF

conn kbrwvpn

  right=vpnovh.cloud.kbrwadventure.com

  rightid=vpnovh.cloud.kbrwadventure.com

  rightsubnet=0.0.0.0/0

  rightauth=pubkey

  leftsourceip=%config

  leftauth=eap-mschapv2

  eap_identity=$1

  auto=start

# END KBRWCONF

EOF

echogreen "Did put new ipsec configuration in /etc/ipsec.conf"

cat >> /etc/ipsec.secrets <<EOF

# START KBRWCONF

$1 : EAP "$2"

# END KBRWCONF

EOF

echogreen "Did put new ipsec configuration in /etc/ipsec.secrets"

cat > /etc/ipsec.d/cacerts/kbrwVpnCACert.pem <<EOF

-----BEGIN CERTIFICATE-----

MIIFMjCCAxqgAwIBAgIILKoE3SX2A8wwDQYJKoZIhvcNAQEMBQAwNzELMAkGA1UE

BhMCRlIxDTALBgNVBAoTBEtCUlcxGTAXBgNVBAMTEEtCUlcgVlBOIFJvb3QgQ0Ew

HhcNMTgwMTA4MTgxOTM0WhcNMjgwMTA2MTgxOTM0WjA3MQswCQYDVQQGEwJGUjEN

MAsGA1UEChMES0JSVzEZMBcGA1UEAxMQS0JSVyBWUE4gUm9vdCBDQTCCAiIwDQYJ

KoZIhvcNAQEBBQADggIPADCCAgoCggIBAMiTNvLh9yIeRmmPYyx9bUhhpMGc2k1N

rdjpEOTz2f/K4sLpO9UYqLwkiT63TKAAsslK41EVVTaUWv0TUoC14EZRnz3ac8MP

Cvh3vIXT4wP/nCd8Po6gOE3/ENyJWKePQOzBfWINFxW5CJEq+krzLZIl12rXyf+u

l4p5scVCJYqG+LXvJOdETuBuEH8SguiKG+9jcb66hqfUW064Iv5M21s5N+4c38T3

cgTw7y+KMScTY8CJif2BBCkNKp7ToQznmC47QDBIer2LxbtkAy7Yu4dRkDoEyoNk

1Y/4Rle5zWWJAMvpdGqOM3E8i+uObract3SaaZSy2HVPUQ+tq/PGUCL/lZndlvPi

Ir9+5ZjTwvRvnbPwnOdgeYBPzRR0Ml1jhiIQEqNaBx6rZeWIl4v6infuDI2Irx+G

b/zbntwQc/pmJku5hBX8zE8eBPvcn/gEzDyiVi/rvi63hLuewyoCpA/b+AyPui41

Mv8cEeGTnnCdl6HNvT8N5p2sWJjnt5HCLYG/7JVoQedDBmZAodJL86lbWJE+gqx0

FaMEtZtm02tShREOdMq5RTro/CUO0edeanZPuDyqmEqPCre6slFOvdhedvQSta/E

PcYT2y1FFHnE7WDDL14mduX8GEJNRTFzYYdT2CNdEBF68w0q86oawJDMGK5wlqV7

lLRmf7Ygf7NHAgMBAAGjQjBAMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQD

AgEGMB0GA1UdDgQWBBRyaVo/NWKHj4979oTvQOw9Dh+TMjANBgkqhkiG9w0BAQwF

AAOCAgEASFpaQ87I2TZnbE/JjJbUh0BYd8Cu2VpghYlxcj+Pgdr0vDBenRpX7LSN

fmMoc2ZnQwsJJGjlcpnGCCQNvr76jaHYphgP6UnOcAmHCH1BStispSa1DJpWypyt

fT8ojdrME9DxnAACmUpkhdWPfOJU5P4fyHmeoefz5wO+wvCAikfBI0GIFXv/iQVo

dC0T1H9AttSHQ1vRSxAoEXlUg5yj7k0J5wcAWbg/4VSk1deILdm+jpM62geHK9jE

CYEMhvsqgDNVMN8t9lgcg5F+R+L1baXdrUCFe6yM030f1b8riVl1tCvylOmKz5ly

MEmU/Ley0ZMgsOwqDUe6yuYVi8VJ3cv3vMG0B/KguBt7TsKtmUDAsUtwIFSxPLXg

Q0p72ZdExY0OxSD5OIjpumRemig3JNbFC3cg4WiLI7lRTQ92mKP0p5LtlR7Xux4O

nJU1pOtt46Q6E4DGKAapwpFg+M9ImwjMOMa9TL7DPHAJlv2Gie0cF2fNw3oRK2ty

JOS9L447Y4MRg2FuAyaT0j/qd98CeVbkXhevFUoxKlZpwgCYPU5riDAh5NEH5Xx/

sDwxuraouk1PpNMboLEnApTrYhNeZzwGtIhpLlz5wWkdmgUYkoziPrphbys4cRTf

8okLPqcekK7QqyvsMHl53668bzqkAYcClzD0QBzDUiS7AvMbWNc=

-----END CERTIFICATE-----

EOF

echogreen "Did trust KBRW CA Certificate: put /etc/ipsec.d/cacerts/kbrwVpnCACert.pem"

systemctl restart strongswan

echogreen "Did systemctl restart strongswan"

sleep 2

ipsec status | grep "INSTALLED"

echogreen "THE VPN IS WORKING !! now systemctl enable strongswan"

systemctl enable strongswan

echogreen "THE VPN is now starting at startup !!!"


