#!/usr/bin/env ruby
# encoding : utf-8
# ©2015 Jean-Hugues Roy. GNU GPL v3.

require "csv"
require "open-uri"
require "dropbox_sdk"
require "google/api_client"
require "google_drive"

# On définit 3 variables à partir de la date à laquelle on se trouve: année, mois et jour

annee = Time.new.year
mois = Time.new.month
if mois.to_i < 10
	mois = "0#{mois}"
else
	mois = mois.to_s
end
jour = Time.new.day
if jour.to_i < 10
	jour0 = "0#{jour}"
else
	jour0 = jour
end

# On définit 2 variables avec les sections qui ne changent pas dans l'URL du Newseum

url1 = "http://webmedia.newseum.org/newseum-multimedia/dfp/jpg"
url2 = "/lg/"

# On définit une fonction pour transformer nos mois en anglais, car c'est ce qu'on va utiliser plus tard dans nos noms de fichier

def month(mo)
	case mo
		when "01"
			m = "Jan."
		when "02"
			m = "Feb."
		when "03"
			m = "March"
		when "04"
			m = "April"
		when "05"
			m = "May"
		when "06"
			m = "June"
		when "07"
			m = "July"
		when "08"
			m = "Aug."
		when "09"
			m = "Sep."
		when "10"
			m = "Oct."
		when "11"
			m = "Nov."
		when "12"
			m = "Dec."
	end
	return m
end

# On se connecte à l'API de Google Drive afin de pouvoir lire la feuille Google qui contient les titres qu'on veut aller chercher

id = ENV["GOOG_USR"]
codeSecret = ENV["GOOG_SECRET"]
refreshToken = ENV["GOOG_JETON"]

client = Google::APIClient.new(
  :application_name => ENV["GOOG_APPLI"],
  :application_version => '1.0.0'
)

auth = client.authorization
auth.client_id = id
auth.client_secret = codeSecret
auth.scope =
    "https://docs.google.com/feeds/ " +
    "https://docs.googleusercontent.com/ " +
    "https://spreadsheets.google.com/feeds/"

auth.redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
auth.refresh_token = refreshToken
auth.refresh!
access_token = auth.access_token
session = GoogleDrive.login_with_oauth(access_token)

cleFeuille = ENV[GOOG_FEUILLE]

j = session.spreadsheet_by_key(cleFeuille).worksheets[0]

# Fonction pour aller chercher les premières pages

def cueillette(url1,url2,jour,jour0,j,ligne,jetons,mois,annee)

	url = "#{url1}#{jour}#{url2}#{j[ligne,3]}"
	puts url
	jornal = j[ligne,1].to_s

	# On vérifie si l'image est disponible sur le site du Newseum

	urlimagem = URI.parse(URI.encode(url))
	result = Net::HTTP.start(urlimagem.host, urlimagem.port) { |http| http.get(urlimagem.path) }
	puts "Code pour le #{jornal} = #{result.code}"

	# Si l'image de la première page est là, le serveur nous retourne le code "200"

	if result.code == "200"
		puts "On ramasse #{jornal}"

		# On se connecte à l'API de Dropbox au moyen de deux jetons d'accès, le mien et celui de mon collègue, placés dans la variable jetons

		jetons.each do |jeton|

			clientDropbox = DropboxClient.new(jeton)

			puts "On se connecte au compte suivant:", clientDropbox.account_info().inspect

			# On copie l'image sur mon disque dur

			File.open("#{annee}#{mois}#{jour0}-#{jornal}.jpg", 'wb') do |file|
				file.write open("#{urlimagem}").read
			end

			sleep(5)

			# On va ensuite placer l'image dans la Dropbox de la personne à qui appartient le jeton d'accès auquel on est rendu

			moisAng = month(mois)
			fich = open("#{annee}#{mois}#{jour0}-#{jornal}.jpg")
			response = clientDropbox.put_file("#{jornal} - #{moisAng} #{jour}, #{annee}.jpg", fich)

		end

	# Si l'image de la première page n'est pas là et que le serveur nous retourne le code "404", ou si on éprouve tout autre problème (erreur du serveur ["500"], par exemple), on passe

	else
		puts "Le #{jornal} n'est pas en ligne"
	end

end

# On définit une fonction jetons pour pouvoir répéter l'opération avec autant d'abonnés Dropbox que nécessaire

jetonYo = ENV["DROPBOX_JETON_JH"]
jetonBraz = ENV["DROPBOX_JETON_BRAZISSIMO"]

jetons = [
	jetonYo,
	jetonBraz
]

fich = Dir["*.jpg"]

x = 0

fich.each do |f|
	if f[0..7] == "#{annee}#{mois}#{jour0}"
		x += 1
	end
end

if x > j.num_rows - 2

	puts "On ne roule pas, on a ce tout qu'il faut."

elsif x == 0

	puts "On n'a aucun journal; on va tout chercher."

	(2..j.num_rows).each do |ligne|
		cueillette(url1,url2,jour,jour0,j,ligne,jetons,mois,annee)
	end

else

	puts "Journaux ramassés: #{x}. On va chercher ce qui manque..."

	jornais = []

	(2..j.num_rows).each do |ligne|
		jornais.push j[ligne,1].to_s
	end

	puts "Tous les journaux = #{jornais}"

	unes = Dir["*.jpg"]

	unes.each do |une|
		if une[0..7] == "#{annee}#{mois}#{jour0}"
			jornais.each do |jnal|
				if jnal == une[une.index("-")+1..-5]
					jornais.delete(jnal)
				end
			end
		end
	end

	puts "Journal(aux) qui manque(nt): #{jornais}"

	jornais.each do |jornal|
		(2..j.num_rows).each do |ligne|
			if j[ligne,1].to_s == jornal
				cueillette(url1,url2,jour,jour0,j,ligne,jetons,mois,annee)
			end
		end
	end
	
end
