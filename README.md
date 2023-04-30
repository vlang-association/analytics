# VOSCA Analytics

[![Association Official Project][AssociationOfficialBadge]][AssociationUrl]

![](https://user-images.githubusercontent.com/51853996/235336784-b23934af-848b-40b7-a9c2-4e13aa53e33d.png)

This repository contains an analytics server that is used for VOSCA sites, a JavaScript script that
sends analytics event to the server, and a dashboard that displays the collected data.

- `/js` — sources of the JavaScript script
- `/cnd/analytics-server.v` — sources of the analytics server
- `/cnd/dashboard` — sources of the dashboard

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
