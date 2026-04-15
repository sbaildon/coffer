# Coffer

Simple secret management for serivces, integrating with systemd

## Installation

Coffer installs as a systemd [portable service](https://systemd.io/PORTABLE_SERVICES/),
and you may need to install `portablectl` if it's not available by default
with your distribution

```bash
dnf install -y systemd-container
```

Install [age](https://age-encryption.org), as Coffer requires shelling out for credential management

```bash
dnf install -y age
```

Install Coffer

```bash
git clone https://github.com/sbaildon/coffer
make 
make install
portablectl attach coffer
systemctl enable --now coffer.socket
```

Create the keys used to encrypt and decrypt credentials

```bash
# create an age identity. keep this secret
age-keygen -pq | systemd-creds encrypt - /etc/credstore.encrypted/coffer.identities.localhost

# generate a public key to be used for encryption
systemd-creds decrypt /etc/credstore.encrypted/coffer.identities.localhost \
    | age-keygen -y > /etc/credstore/coffer.recipients.localhost
```

### Extra recipients and identities

Any `coffer.identities.*` or `coffer.recipients.*` files located in
the standard [systemd-creds](https://www.freedesktop.org/software/systemd/man/latest/systemd-creds.html) search paths, `/usr/lib/credstore` and
`/etc/credstore/`, including the `.encrypted` equivalents; will be used
by Coffer to encrypt (recipients) or decrypt (identities). Recipient
and identity files take a form understood by age, typically a newline
delimited list of keys.

> [!NOTE]
> You will eventually lose access to credentials if you use only the quick-start identity.
> The quick-start identity is encrypted with a key unique to the machine where the command is run. Loss of the machine means loss of the encryption key, thus all credentials.
> It's recommended you create at least one more age identity on a remote machine that can be backed up.
>
> From a machine where Coffer is _not_ running:
>
> `age-keygen -pq > coffer_identity`
>
> `scp <(cat coffer_identity | age-keygen -y) root@remote:/etc/credstore/coffer.recipients.laptop`
>
> Be sure to back up `coffer_identity`

## Usage

The Coffer protocol is simple:

Send a binary message framed with a `SET`, `GET`, or `DELETE` action, the id of the credential, terminated with `\n`.
In the case of `SET`, the credential's content is everything following the `\n` after the id.

```bash
printf "SET myapp.stripe_secret_key\n%s" sk_test_abc | socat - UNIX-CONNECT:/run/coffer.socket
```

```bash
printf "GET myapp.stripe_key\n" | socat - UNIX-CONNECT:/run/coffer.socket
```

```bash
printf "DELETE myapp.stripe_key\n" | socat - UNIX-CONNECT:/run/coffer.socket
```

## Systemd Credentials

Coffer integrates with the [`LoadCredential=`](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#LoadCredential=ID:PATH) directive of systemd. One can use Coffer to load a credential into a given service

```ini
[Service]
LoadCredential=myapp.stripe_secret_key:/run/coffer.socket
```

```bash
systemd-run --pty --property=LoadCredential=myapp.stripe_secret_key:/run/coffer.socket -- bash -c 'cat $CREDENTIALS_DIRECTORY/myapp.stripe_key'
```
