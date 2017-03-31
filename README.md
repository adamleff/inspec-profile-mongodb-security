# mongodb-security - InSpec Profile for MongoDB Security Checklist

This profile provides a number of controls to ensure aspects of the [MongoDB Security Checklist](https://docs.mongodb.com/manual/administration/security-checklist/) are implemented on your host.

## Configuration

Some of the controls in this profile require using the `mongo` CLI client to connect to the running `mongod` process and verify the existence of roles and users. Therefore, the username and password of a user with the `userAdmin` role on the `admin` database is required.

You may supply the username and password via an InSpec attributes YAML file. Here's an example:

```yaml
username: myAdminUser
password: s00pers33kret
```

It is assumed that the MongoDB process has SSL enabled and will attempt to contact the `mongod` process with SSL enabled.

You may also supply any of the following additional attributes:

 * **conf_file**: path to the `mongod.conf` YAML configuration file. Default: `/etc/mongod.conf`
 * **verify_ssl**: if false, verification of the SSL certificate will be disabled when connecting to `mongod`. This may be necessary if you are using a self-signed certificate or using your own Certificate Authority. Default: `true`
     * **NOTE**: Due to a bug in InSpec, you cannot set this to a YAML boolean of `false`. Instead, you must supply this parameter as a string. For example:

```yaml
verify_ssl: 'false'
```

## Running the Profile

Once you have created your attributes YAML file, simply run InSpec against your host:

```bash
inspec exec https://github.com/adamleff/inspec-profile-mongodb-security -t ssh://USER@IPADDRESS --attrs /path/to/attributes.yml
```

## Modifying the Profile

You can disable or modify any of these controls if they do not apply to your environment. Learn more by reading the **Profile Dependencies** section of the [profile documentation page](http://inspec.io/docs/reference/profiles/) on [inspec.io](http://inspec.io).

## Contributing

Do you have an awesome control to add to this profile? Have a bug you'd like to fix. We'd love to review your pull request!

1. Fork it ( https://github.com/adamleff/inspec-profile-mongodb-security/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

|  |  |
| ------ | --- |
| **Author:** | Adam Leff (<adamleff@chef.io>) |
| **Copyright:** | Copyright (c) 2017 Chef Software Inc. |
| **License:** | Apache License, Version 2.0 |

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

