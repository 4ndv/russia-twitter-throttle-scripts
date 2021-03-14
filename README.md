# Twitter Russia Slowdown

## Getting started

For working with this scripts, you'll need:

- Docker with Compose (optional)
- Ruby 2.7.x

To run without Docker, edit `config/database.yml`, it's in Rails's format

Run following commands to get started:

- `gem install bundler rake pry`
- `bundle`
- `docker-compose up` (in separate window, if needed)
- `rake db:create`
- `rake db:migrate`

## Data

The data I process is nginx's "access.log" with entries like this:

```text
1.2.3.4 - - [11/Mar/2021:19:44:00 +0000] "GET /log.png?test=8620.69&control=11673.15&controlTaco=16666.67&v=4 HTTP/1.1" 200 95 "https://lynx.pink/" "Mozilla/5.0"
```

Where `1.2.3.4` is an IP, `11/Mar/2021:19:44:00 +0000` is a date, `/log.png?test=8620.69&control=11673.15&controlTaco=16666.67&v=4` is a logger line, and `Mozilla/5.0` is an User-Agent

The query parameters meaning:

- `test` - time required to load ~3000 bytes from `abs.twimg.com`, which is slowed down in Russia
- `control` - time required to load control image from server which should not be slowed down in Russia
- `controlTaco` - time required to load control image from server with `t.co` in a hostname, which WAS also slowed down in Russia by a mistake from Roskomnadzor
- `v` - version of test, different versions may have different methods of loading images and different control servers

The data must be placed in `data/final.log`

How I prepared data:

```bash
cat access* | grep -F "log.png" | sort -u > final.log
```

Where `access*` is a glob pattern for source files, `log.png` is a name of a image that I've used for logging

After preparing data, you'll need to run this:

```bash
ruby scripts/load_from_log.rb
```

It may spit out couple of validation errors, you can (mostly) ignore it

### IP to ASN data

The data I'm using is from CAIDA and requires citation like this:

```text
The CAIDA UCSD [DataSet Name] - [dates used],
https://www.caida.org/data/[dataset-URL]
```

Or like this:

```text
Routeviews Prefix to AS mappings Dataset for IPv4 and IPv6 https://www.caida.org/data/routing/routeviews-prefix2as.xml
```

The data itself: [https://www.caida.org/data/routing/routeviews-prefix2as.xml](https://www.caida.org/data/routing/routeviews-prefix2as.xml)

You must download newest copy for IPv4 **and** IPv6 and put it in `data/pfx2as`. There must be two files with the names like `routeviews-rv2-date-time.pfx2as` and `routeviews-rv6-date-time.pfx2as`

Then, for import the data run this script (**WARNING!** it will delete all the data from `as_prefixes` table!):

```bash
ruby scripts/load_pfx2as.rb
```

### AS organizations and countries data

The data is also provided by CAIDA and requires citation:

```text
The CAIDA UCSD AS to Organization Mapping Dataset, <date range used>
https://www.caida.org/data/as_organizations.xml
```

To download the data you must fill the form [here](https://www.caida.org/data/request_user_info_forms/as_organizations.xml), and after that you'll be redirected to the download. Download the `jsonl` version!

Then you must place it in `data/as_organizations` and the file should be called like `date.as-org2info.jsonl`

Then run this script (**WARNING!** it will delete all the data from `as_organizations` table!):

```bash
ruby scripts/load_as_organizations.rb
```

### Assigning ASN-s and Subnets

To assign ASNs and Subnets to imported data, open `pry` and use this command:

```ruby
Log.assign_asn_and_subnets!(ignore_existing: true)
```

`ignore_existing` does not run this for entries that already has `asn` and `subnet` fields. If you want to reassign it again, run with `ignore_existing: false`
