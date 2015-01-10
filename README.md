0) Captvty is no free software but is free, please check its license at:

	http://captvty.fr/

1) Build the image

	# docker build -t captvty .
	# DEBUG: docker build --rm=false -t captvty .

2) First launch and configuration

	# xhost +local:
	# docker run -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix captvty

	#
	# Configure captvty as needed
	# for example:
	# in "Téléchargement et nom de fichiers":
	#	- supprimer les accents
	#	- créer un sous-dossier portant le nom de la chaîne
	#	- choisir le dosier de destination pour ~luser/downloads
	#
	# Save your config:
	# find the last instance using 'docker ps -a | head'
	# docker commit <container_id> captvty

4) Setup a shared directory
Captvty needs a writable directory (777) to save/export its downloads.
For example you can use your /tmp.

4) Now you can use captvty using:

	# xhost +local:
	# docker run -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v /tmp:/home/luser/downloads captvty




