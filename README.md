# TG2SIP Gateway

TG2SIP is a `Telegram <-> SIP` voice gateway. It can be used to forward incoming telegram calls to your SIP PBX or vice versa.

## Requirements

Your SIP PBX should be comaptible with `L16@48000` or `OPUS@48000` voice codec.

## Usage

1. Obtain binaries in one of convenient ways for you.
2. Obtain `api_id` and `api_hash` tokens from [this](https://my.telegram.org) page and put them in `settings.ini` file.
3. Login into telegram with `gen_db` app
4. Set SIP server settings in `settings.ini`
5. Run `tg2sip`

`SIP -> Telegram` calls can be done using 3 extension types:

1. `tg#[\s\d]+` for calls by username
2. `\+[\d]+` for calls by phone number
3. `[\d]+` for calls by telegram ID. Only known IDs allowed by telegram API.

All `Telegram -> SIP` calls will be redirected to `callback_uri` SIP-URI that can be set in from `settings.ini` file.
Extra information about Telegram account caller will be added into SIP headers:

* `X-TG-Context`: Special header for debug purpose
* `X-TG-ID`: Telegram User Id
* `X-TG-FistName`: Optional, User first name
* `X-TG-LastName`: Optional, User last name
* `X-TG-Username`: Optional, User username
* `X-TG-Phone`: Optional, User phone number


## Build binaries

```bash
git clone https://github.com/hectorvent/tg2sip
cd tg2sip

./build.sh

# build directory will be create and gen_db, tg2sip and settings.ini will exist
```

# Running on:

## Running on debian

```bash
# Install dependencies.
apt install libopus0 libssl1.1 -y

# Create directory structure
mkdir /etc/tg2sip
mkdir /var/tg2sip

cp build/{tg2sip,gen_db} /usr/local/bin

# nano/vi /etc/tg2sip/settings.ini and change necessary values.
cp settings.ini /etc/tg2sip/

# Copy systemd service
cp tg2sip.service /etc/systemd/system
systemctl daemon-reload

# create Telegram Tdlib db and fill the requested information
sudo TG2SIP_STANDARD_FOLDER=YES gen_db

# start the tg2sip gateway and enjoy it.
systemctl start tg2sip.service
```

## Running on docker

```bash
cd docker
cp ../settings.ini etc
# Edit settings file
nano etc/settings.ini

# Generate Telegram db
docker run --rm -it -v `pwd`/etc:/etc/tg2sip/ -v `pwd`/data:/var/tg2sip/  hectorvent/tg2sip-gateway gen_db

# start docker services
docker-compose up -d
```

## Todo:

- Upgrade `Tdlib` to new version.
- Integration examples with `Asterisk`, `FreeSwitch` and `Kamailio`.
- A better Tdlib db initialization process. It is possible to create an API.

## Donate

As this repo is based on [Infactum/tg2sip](https://github.com/Infactum/tg2sip) make donation to Infactum.
