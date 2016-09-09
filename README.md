# Brasil <span>&#x1f1e7;&#x1f1f7;</span>
Un collègue a mis en ligne, en 2015, un site web en lien avec les Jeux Olympiques de Rio.
Il voulait notamment y intégrer les premières pages de certains quotidiens, [diffusées tous les matins par *Newseum*](http://www.newseum.org/todaysfrontpages/?tfp_display=gallery&tfp_region=South%20America&tfp_sort_by=country).
Il souhaitait aussi que les premières pages soient déposées le plus rapidement possible dans sa boîte Dropbox.

Le script inclus dans ce répertoire a été conçu pour être lancé, grâce à un [cronjob](https://fr.wikipedia.org/wiki/Cron), à toutes les cinq minutes entre 6h et 10h tous les matins, sept jours sur sept (car le Newseum ne disposait pas ses premières pages toujours à la même heure).

Le script commence par consulter une [feuille Google](https://docs.google.com/spreadsheets/d/1Ml9-iLqX4QnQcK0MSgm6il6_-xL27W5T6Wl1Rrg06Vs/edit#gid=1497059474) contenant la liste des journaux dont on souhaite récupérer les premières pages. Mon collègue pouvait changer cette liste pour inclure ou exclure autant de journaux qu'il le souhaitait. Pour chaque journal, il fallait indiquer son titre, sa ville et un code utilisé par Newseum (pour *O Globo*, par exemple, ce code est `BRA_OG.jpg`). Pour ce faire, le script utilise l'[API de Google Sheets](https://developers.google.com/sheets/).

Le script vérifie ensuite, pour chaque journal, si sa première page se trouve sur le site du Newseum. Si elle y est, il la copie sur mon disque dur, puis dans les boîtes Dropbox de différentes personnes au moyen de l'[API de Dropbox](https://www.dropbox.com/developers/documentation/http/overview).

Le script a roulé durant toute l'année précédant les JO de Rio. Je l'ai maintenant déconnecté.
