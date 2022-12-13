# Vdmc-Core
This package contains the vdmc-core setup for Apex development. It contains DI, trigger framework over several packages up to the Nebula logger with Sentry integration.

## Dependency Injection
Dependency injection provides a pattern for larger custom software solutions. It forces the developer
to access the business logic only through a facade. The facade itself can be fetched via Dependency Injection
from anywhere. All retrieved services are cached for the current session. This enables the reduction of unneeded,
class initialization.

## Trigger Framework (forked from [codefriar](https://github.com/codefriar/DecouplingWithSimonGoodyear))
Based on the trigger framework from codefriar, it includes additional changes. It includes feature toggles for specific TriggerHandler
via the "Active__c" flag on the MDT object.

## Nebula-Logger (used from [jongpie](https://github.com/jongpie/NebulaLogger))
Take a look at the linked repository. It's just a great logging framework that Salesforce never had.

### Sentry Integration
Own implementation to also transmit occuring events to sentry. It simply allows to better monitor multiple
environments.

### Old sfdx-project with dependencies
In order to build and disctribute the vdmc-core package, we should delete unreleted dependencies from the 
sfdx-project.json file. Here is the last version of the fiel with all dependecies:

{
    "packageDirectories": [
        {
            "package": "Nebula Logger Plugin - VdmcSentry",
            "path": "vdmc-sentry-app",
            "dependencies": [
                {
                    "package": "Nebula Logger - Unlocked Package@4.7.1.1"
                }
            ],
            "versionName": "Alpha",
            "versionNumber": "0.0.1.NEXT",
            "versionDescription": "Initial Sentry integration for Nebula Logger",
            "default": false
        },
        {
            "package": "VdmcCore",
            "path": "vdmc-core-app",
            "dependencies": [
                {
                    "package": "Nebula Logger - Unlocked Package@4.7.1.1"
                },
                {
                    "package": "Nebula Logger Plugin - VdmcSentry",
                    "versionNumber": "0.0.1.LATEST"
                }
            ],
            "versionNumber": "0.0.1.NEXT",
            "default": true
        },
        {
            "package": "VdmcExample",
            "path": "vdmc-example-app",
            "versionName": "VdmcExample",
            "versionNumber": "0.0.1.NEXT",
            "default": false
        }
    ],
    "name": "vdmc-core",
    "namespace": "",
    "sfdcLoginUrl": "https://login.salesforce.com",
    "sourceApiVersion": "54.0",
    "packageAliases": {
        "Nebula Logger - Unlocked Package@4.7.1.1": "04t5Y0000015lgBQAQ",
        "Nebula Logger Plugin - Logger Admin Dashboard@0.9.0-0": "04t5Y0000015l3yQAA"
    }
}