# brigadeappv2

A new Flutter project REFACTOR (YEEEY).

## NOTES.

This project is a starting point for a Flutter application.

The resources that we used for the refactor:

- [Case study](https://docs.flutter.dev/app-architecture/case-study)

1. Most of the application code lives in the data, domain, and ui folders. The data folder organizes code by type, because repositories and services can be used across different features and by multiple view models. The ui folder organizes the code by feature, because each feature has exactly one view and exactly one view model.

2. The UI folder also contains a subdirectory named "core". Core contains widgets and theme logic that is shared by multiple views, such as buttons with your brand styling.

3. The domain folder contains the application data types, because they're used by the data and ui layers.

4. Data layer objects (repositories and services) aren't tied to a single feature, while UI layer objects (views and view models) are. 