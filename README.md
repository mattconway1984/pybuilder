PyBuilder
=========

## Overview

The *PyBuilder* is a "build system" which aims to provide a simple method
to build, check, test and publish Python projects. 


## Design

The *PyBuilder* has been designed in such a way that it can be used both 
locally (i.e. on a developers workstation) and on a continuous integration 
server (i.e. by a Jenkins server). The "code" that makes up the *PyBuilder*
has a  strong emphasis on simplicity, ensuring that maintainance burdens are 
kept as low as possible.

### Versioning

One tricky aspect that comes with developing a multi-developer Python project
is coming up with a versioning workflow that works, but is also very simple.
For this reason, a descision was made to make use of an external versioning
tool, namely [*Python Versioneer*](https://pypi.org/project/versioneer/). 
This tool does versioning based on Git tags, so no effort is required to ensure
versions are kept in sync across multiple files in the project. The version
comes from one place, the Git tag, and Git describe is used to create PEP440
compliant version numbers. 
Any Python project that incorporates the *PyBuilder* must ensure that 
versioneer has also been "installed" into the project; if this has not already
been done, refer to the Integration instructions below.

## Integration Instructions

This section describes how to integrate the *PyBuilder* into your Python
project, and how to update to the latest version.

### Installing PyBuilder

This section describes the steps required to install the *PyBuilder* into
your Python project.

#### 1. Add Requirements

The *PyBuilder* relies on [requirements files](https://pip.readthedocs.io/en/1.1/requirements.html)
You must specify both requirements.txt (for "deployment") and 
requirements-dev.txt (for "development") which are used to install the correct
Python dependencies. For example, a requirements file could be:

requirements.txt
```
# Dependencies:
grpcio
```

requirements-dev.txt
```
# bring in requirements from distribution
-r requirements.txt

# Requirements for development: 
grpcio-tools
```

#### 2. Setup Versioneer

This section describes how to install and configure Versioneer, which is used to
automatically generate the version for your Python project.

##### 1. Install versioneer

To install versioneer into your project, install versioneer using pip, for 
example:

```
[user@machine]$ pip install versioneer
```

##### 2. Modify `setup.py`

You will need to modify `setup.py` (in the root of your project) so that the 
version number is retrieved using Versioneer, as opposed to being hardcoded 
(or pulled in from another external location). For example:

```
from setuptools import setup
import versioneer

setup(
    name="my_project",
    version=versioneer.get_version(),
    cmdclass=versioneer.get_cmdclass(),
)
```

##### 3. Create a `setup.cfg`

You will need to create a `setup.cfg` (in the root of your project) which is
used by setuptools, add a section which describes configuration details for
Versioneer, for example, this is the recommended configuration:

```
[versioneer]
VCS = git
style = pep440
versionfile_source = my_project/_version.py
versionfile_build = my_project/_version.py
tag_prefix = ""
```
<b>Note 1:</b> Don't forget to replace *my_project* with the name of your Python 
project! 
<b>Note 2:</b> *my_project*/\_version.py will be automatically created by 
Versioneer

##### 4. Install Versioneer into your project

The final step is to install versioneer into your Python project. 

<b>Note:</b> Ensure *pwd* is the root directory of your project before executing
this step.

Run the following command:

```
[user@machine]$ versioneer install
```

This will automatically generate some files which are used to automatically
generate version numbers for your project. Running this command will also 
invoke `git add` for the generate files, you can check this by running 
`git status` to view the list of staged files. 

Ensure the following files have been staged (`setup.py` will not be 
automatically staged):

```
[user@machine] git status
...
	new file:   .gitattributes
	new file:   .gitmodules
	new file:   MANIFEST.in
	new file:   avcadlib/_version.py
	new file:   builder
	modified:   setup.py
	new file:   versioneer.py
...
```

##### 5. Verify installation

To verify that Versioneer has been successfully configured for your Python 
project you can run the following command:

```
[user@machine]$ python setup.py --version
```

Which should report a sensible version.

<b>NOTE:</b> You need to ensure that your project contains an annotated tag
which describes the version, i.e. `<MAJOR>.<MINOR>.<PATCH>`. If your tag 
contains letters, it will cause a warning, for example if the tag is `v1.0.0r`, 
you will get a warning, for example:

```
/usr/lib/python3.6/site-packages/setuptools/dist.py:472: UserWarning: Normalizing 'v1.0.0r+0.g4fa0b38.dirty' to '1.0.0.post0+0.g4fa0b38.dirty'
```

To fully understand the version number, refer to Versioneer documentation, which
can be found from this location: https://pypi.org/project/versioneer/


#### 2. Install PyBuilder

At the root of your project, you will need to create a Git submodule which links
to the *PyBuilder*; this is done by running the following command:

```
[user@machine]$ git submodule add <PYBUILDER> 
```

The result should be that the builder repository is now cloned into your 
project (as a git submodule), for example:

```
my_project
 |
 |-- setup.py
 |-- mypymodule
 |-- builder
```

### Updating PyBuilder

To update *PyBuilder* once it has been integrated into your project, all you
need to do is run the following commands:

```
[user@machine]$ git submodule update --init --remote --force
[user@machine]$ git add builder
[user@machine]$ git commit -m "Updating to latest PyBuilder"
```

### Usage

The *PyBuilder* is designed so that it can be invoked from any $(pwd) when
developing inside your project. The *PyBuilder* will create a new Docker
image inside which a clean environment will be created to build/check/test
the Python project.

To invoke the *PyBuilder* simply execute the following command:

```
[user@machine]$ ./builder/env.sh make <RULE>
```

Where <b>RULE</b> must be set to one of the following:

|Rule | Description |
|:-------------|:-----------------------------------------------------------------------------------|
|docs-clean | Clean the built documentation |
|clean | Clean the built artifacts (Python wheel) |
|test | Run pytest to execute all tests (under *my_project*/tests) |
|check | Run pylint on the Python project (ignore pylint errors) |
|check-strict | Run pylint on the Python project (don't ignore pylint errors) |
|wheel | Build a Python wheel for the Python project |
|docs | Build the documentation package (under *my_project*/docs) |
|publish | Used by Jenkins to build and publish the built Python wheel (runs pytest) |
|publish-strict| Used by Jenkins to build and publish the built Python wheel (runs pytest & pylint) |
|publish-docs | Used by Jenkins to build and publish the documentation package |
