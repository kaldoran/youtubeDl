#!/bin/bash

# REYNAUD Nicolas le Samedi 1 juin 2013.
# SCRIPT RECUPERATION MUSIQUE YOUTUBE 

function print_usage() {
  echo -e "\n\t\t\t\033[01;05mGET YOUTUBE MUSIQUE BY REYNAUD NICOLAS\E[0m\nPlease DO NOT delete the previous sentence.Thx\n\n"
}

# Fonction récuperé sur ce site
# http://mywiki.wooledge.org/BashFAQ/071
ord() {
  LC_CTYPE=C printf '%d' "'$1"
}

#Affiche le temps en milliseconde
timemilli() {
	echo $(($(date +%s%N)/1000000));
}

#permet de generer un code utile a la récuperation de la musique
code() {
	AM=65521;
	b=1;
	c=0;
	chaine=${1};
	for i in $(seq 0 $((${#chaine} - 1))); do 
		d=${chaine:$i:1};
		d=$(ord $d); 
		b=$(($((b+d)) % AM));
		c=$(($((c+b)) % AM));
	done
	echo $(($c << 16 | $b));
}

if test -z "$1"; then
    echo "Erreur : Il faut 1 argument au minimum."
    echo -e "$0 URL_YOUTUBE [Dossier]"
    exit 1
else 
   # v : Version - f : Fichier ou sont contenu les liens - h : Help - i : Telecharger image - d : Dossier ou mettre la musique
   # Version futur : 
   # Choisir le fichier avec l'option -d
   # Récuperer ou non l'image avec l'option -i
   # récuperer toute une liste de musique depuis un fichier
   
   while getopts :vif:d:h option
   do
      case $option in
         i)  ;;
         v)  echo -e "youtubeDl - Version 4.0\nPar Nicolas Reynaud"; exit 1;;
         d) ;;
         f) ;;
         h) print_usage | more; exit 1 ;;
         \?) print_usage | more ; exit -1 ;;
      esac
   done

   shift $(($OPTIND - 1 ))

   id_video=$(echo ${1:(-11)})

   echo -e "\nRécuperation de la vidéo depuis Youtube ...\n"
   wget -q -O tmp "http://www.youtube-mp3.org/a/itemInfo/?video_id=$id_video&ac=www"

   if ! test -s tmp; then
      echo -e "Erreur : Impossible de recuperer la vidéo."
      exit 1
   else
      tr "}" " " < tmp | tr -d "{" | tr -d "\"" | tr -d "[" | tr -d "]" | tr -d ";" |  tr "," "\n" | sed "s/info =  //" | sed "s/^[ \t]*//" | sed "s/length : /durée : /" | sed "s/title : /titre : /"> tmp2
      rm tmp
   
      titre=$(sed -n 's/titre : /&/Ip' tmp2)
      duree=$(sed -n 's/durée : /&/Ip' tmp2)
      img=$(sed -n 's/image : /&/Ip' tmp2)
      hash=$(sed -n 's/h : //Ip' tmp2)
      rm tmp2
   
      echo -e "$titre\n$duree minutes\n$img\n";
      echo "Mise en place de la vidéo sur le serveur."
      for i in $(seq 0 100); do
         echo -ne "Progression : $i%\r"
         sleep 0.1
      done
      echo "Téléchargement de la musique sur votre pc en cours ...."

	 time=$(timemilli);
	 chaine=$id_video$time;
	 code=$(code $chaine);

      wget -O "${titre:8}.mp3" "www.youtube-mp3.org/get?ab=128&video_id=$id_video&h=$hash&r=$time.$code" 2>&1 | mawk -W interactive '/% / {n=2; if($0 ~ /=/)n=1; printf "Progression: %d %%\r",$(NF-n)} END{print ""}'
   
      if test -z "$2"; then
         echo "La musique a été placée dans le repertoire courant."
         exit 1
      else
	      if [ ! -e "$2" ] ; then
	         mkdir "$2"
	         mv "${titre:8}.mp3" "$2"
            echo -e "Musique placée dans le dossier $2." 
	      else
	         if [ ! -d "$2" ] ; then
	            echo -e "Erreur . $2 n'est pas un dossier"
	         else
	            mv "${titre:8}.mp3" "$2"
               echo -e "Musique placée dans le dossier $2." 
            fi
	      fi
      fi 
   fi
fi 

#echo $(($(date +%s%N)/1000000))
#id="42khBI1dQWA";
#time=$(($(date +%s%N)/1000000));
#chaine=time+id;
#for i in $(seq 0 $((${#chaine} - 1))); do echo ${chaine:$i:1}; done


