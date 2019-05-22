This is a library that is used by Cypress for QRDA validation. It contains Schematron validators, schema validators, and validators for QRDA-specific features (measure IDs, performance rates, result extraction, etc).

Bug reports and pull requests are welcome on GitHub at https://github.com/projecttacoma/cqm_validators.

Environment
===========

This project currently uses Ruby 2.3, Ruby 2.4, Ruby 2.5 and Ruby 2.6 and is built using [Bundler](http://gembundler.com/). To get all of the dependencies for the project, first install bundler:

    gem install bundler

Then run bundler to grab all of the necessary gems:

    bundle install



Versioning
==========

Starting with version **1.0.1.0** released on 5/22/2019, cqm-validators versioning has the format **W.X.Y.Z**, where:

* **W** maps to a version of QRDA Category 1 and QRDA Category 3. See the table below to see the existing mapping to QRDA versions.

  | W | QRDA Cat 1 | QRDA Cat 3 |
  | --- | --- | --- |
  | 1 | R1 STU5.1 | R1 STU2.1 |

* **X.Y.Z** uses [SemVer](http://semver.org/) for versioning. **X.Y.Z** starts at 0.0.0 when **W** is incremented.

For the versions available, see [tags on this repository](https://github.com/projecttacoma/cqm-validators/tags).


Project Practices
=================

Please try to follow the [GitHub Coding Style Guides](https://github.com/styleguide). Additionally, we are switching to the git workflow described in [Juan Batiz-Benet's Gist](https://gist.github.com/jbenet/ee6c9ac48068889b0912). If you are new to the project and would like to make changes, please fork and do your work in a feature branch. Submit a pull request and we'll check to see if it is suitable to be merged in.

License
=======

Copyright 2014 The MITRE Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
