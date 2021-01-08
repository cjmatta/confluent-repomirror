# confluent-repomirror
Download the Confluent Platform RPMs using Yum reposync on a Docker container

## Requirements
* An installtion of Docker
* Internet access

## Usage
All arguments are optional.

`$ download-confluent-repo.sh [ -h | -v 5.3 | -d mydir | --no-cleanup ]`
### Options:

```
-h, --help      show help
-v              Confluent version, defaults to 6.0
-d              Directory to download the repository to, defaults to ./confluent-<version>
--no-cleanup    Don't remove the created docker image, by default this script cleans up after itself
````
