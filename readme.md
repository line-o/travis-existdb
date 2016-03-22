# Running eXistDB on a Continuous Integration Platform

While this setup is specifically for Travis-CI you will possibly find useful information to integrate existDB in other CI platforms as well.

It is language independent but was tested only with Java and nodeJS. Both setups are provided.

You can test applications, that are served from the db or consume one of its APIs.

{{TOC}}

## tl;dr

CI? You should have it.

[The complete setup](http://github.com/line-o/travis-existdb) to test anything against one or more versions of eXistDB on [TravisCI](travis-ci.org) with caching enabled

## Preface 

I was recently working on [node-exist](https://github.com/line-o/node-exist.git). It is a node package, that consumes eXist's RPC API. In order to run the tests the database needed to be up. 

Mocking of the database responses could have solved that problem, but…

**Now you got 2 problems**

1. how to test against another version or multiple ones 
2. validating mock responses (of multiple versions)

A much better solution is for the tests to run on a continous integration platform.
Here, every commit can be tested against different versions of the database in parallel.
And, there is no need to have them runnning on the development machine.
Plus, everyone with access can verify if a certain build is running and which database versions are supported by your application.

There are more arguments pro continuous integration, which you can easily find online.

[TravisCI](https://travis-ci.org) seemed to be a reasonable choice, not only because eXistDB itself runs its automated tests here.

## Which version to test against?

As travis automatically starts one build per entry in `env` your tests will be run against the 3.0.RC1 and the 2.2 release of eXist with

```yaml
env:
  - EXIST_DB_VERSION=eXist-3.0.RC1
  - EXIST_DB_VERSION=eXist-2.2
```

Add or remove versions as you need them.

## before install

It proved to be handy to store the installation folder of the current DB version in an environment variable `EXIST_DB_FOLDER`. It will be used by following scripts and commands.

```yaml
before install:
  - export EXIST_DB_FOLDER=${HOME}/exist/${EXIST_DB_VERSION}
```


## installation and setup

To install the database we download the source from github, extract it and then call its build routine.

```sh
export TARBALL_URL=https://github.com/eXist-db/exist/archive/${EXIST_DB_VERSION}.tar.gz

mkdir -p ${EXIST_DB_FOLDER}
curl -L ${TARBALL_URL} | tar xz -C ${EXIST_DB_FOLDER} --strip-components=1
cd ${EXIST_DB_FOLDER}
./build.sh
```

All of the above can be nicely packed into a [setup script](ci/setup-db.sh).

```yaml
install:
  - ci/setup-db.sh
```

**Note**: `EXIST_DB_VERSION` is the environment variable we defined at the very beginning. This can be a tag or branchname or even a commit hash.

## Can't we start already?

Yes, but in order to do that we have to start eXist in the background and wait for it to listen to requests.
Last, ensure that by doing a very simple one.

```sh
cd ${EXIST_DB_FOLDER}
nohup bin/startup.sh &
sleep 30
curl http://127.0.0.1:8080/exist
```

Yes, you guessed it. There is a [database start-up script](ci/start-db.sh).

```yaml
before_script:
  - ci/start-db.sh
```

**Note**: Without changing to its installation folder a bunch of exceptions will end up in nohup.out complaining about log files that cannot be found and opened.

## That's it

Run your tests!

```yaml
script:
  - do test **/*
```

Now it is time to clean up the closet:

```yaml
after_script:
  - cd ${EXIST_DB_FOLDER}
  - bin/shutdown.sh
```

## Tweaks

### Caching

Downloading and building exist from source can take up to 3 minutes. So, you may want to speed up your tests by caching the built database. The archived cache has still to be loaded from s3 but you will gain an extra minute or so - YMMV.

1. Is this version of existDB already cached? 

	In our case that boils down to: does the folder exist?

	```sh
	if [ -d "$EXIST_DB_FOLDER" ]; then
	  echo "Using cached eXist DB instance: ${EXIST_DB_VERSION}."
	  exit 0
	fi
	```

1. Teardown this Database

	Remove any data that is or might be left behind by your tests and remove logs, too.
	To make sure that you will always get the latest version for branches or refs like HEAD,
	anything but releases should be excluded from caching. 

	```sh
    if [[ "${EXIST_DB_VERSION}" == eXist* ]]; then
        echo "reset data and logfiles for ${EXIST_DB_VERSION}"
        cd ${EXIST_DB_FOLDER}
        ./build.sh clean-default-data-dir
        rm webapp/WEB-INF/logs/*.log
        exit 0 # 
    fi
    
    echo "exclude ${EXIST_DB_VERSION} from cache"
    rm -rf ${EXIST_DB_FOLDER}
	```

Put together:
	
```sh
before_cache:
  - ci/teardown-db.sh
cache:
  directories:
	- ${HOME}/exist
```

## What if Java is not you first language?

If you are not testing a java-application, as I was, you need to install java 1.8 into to the testing container with:

```
addons:
  apt:
    packages:
      - oracle-java8-installer
```

and make this version the default by adding

```
  - export JAVA_HOME=/usr/lib/jvm/java-8-oracle
```

to the **before_install** step.

## The Gist of the Story

(Integration) testing is necessary, so if you're application depends on eXistDB then you should definitely have a look at this project.

[travis-existdb](http://github.com/line-o/travis-existdb)

### contents

- .travis.yml (Java setup)
- node.travis.yml (nodeJS setup)
- ci/* (helper scripts described above)
- utility/* (ant, Java setup utility functions)
- project/* (sample project)
