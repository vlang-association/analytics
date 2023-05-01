# VOSCA Analytics

[![Association Official Project][AssociationOfficialBadge]][AssociationUrl]

![](https://user-images.githubusercontent.com/104449470/235490883-add141c0-4110-4bf4-a806-dbfae1dd6c36.png)

This repository contains an analytics server that is used for VOSCA sites, a JavaScript script that
sends analytics event to the server, and a dashboard that displays the collected data.

- `/js` — sources of the JavaScript script
- `/cmd/analytics-server.v` — sources of the analytics server
- `/cmd/dashboard` — sources of the dashboard

Dashboard is located at: https://analytics.vosca.dev

## Privacy

Analytics does not collect personal data that can be used to identify the user.
It does not use cookies or other technologies to track the user.

We are currently collecting the following information:

- User agent
- Accept language
- Referrer
- Country code and name (**we do not store IP addresses**)
- City name

## License

This project is under the **MIT License**. See the
[LICENSE](https://github.com/vlang-association/analytics/blob/master/LICENSE)
file for the full license text.

[AssociationOfficialBadge]: https://vosca.dev/badge.svg

[AssociationUrl]: https://vosca.dev
