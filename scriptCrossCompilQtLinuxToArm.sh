#!/bin/bash
LIENARM="https://launchpadlibrarian.net/155358238/gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux.tar.xz"
LIENQT="http://download.qt.io/archive/qt/4.8/4.8.5/qt-everywhere-opensource-src-4.8.5.tar.gz"
ARCHIVECOMPILATEUR="gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux.tar.xz"
ARCHIVEQT="qt-everywhere-opensource-src-4.8.5.tar.gz"
VERSIONQT="4.8.5"
DOSSIER="installQt"
COMPILATEUR="gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux"
QT="qt-everywhere-opensource-src-4.8.5"
QMAKECONF="$QT/mkspecs/qws/linux-arm-gnueabi-g++/qmake.conf"
REPERTOIRE="/usr/local/Qt-$VERSIONQT-arm"
HOMESED="\/home\/$USERNAME"
COEUR=$(grep -c ^processor /proc/cpuinfo)

echo "Script pour installer QT dans le but de cross compiler pour une architecture ARM"
echo "Ce script peut prendre un certain temps à s'executer, veuillez patienter"

cd $HOME

if [ -d "$DOSSIER" ]; then
    echo "Dossier $DOSSIER déjà existant, voulez-vous le supprimer ?"
	select yn in "Yes" "No"; do
		case $yn in
			Yes ) echo "Suppression de $DOSSIER"; rm -r $DOSSIER; break;;
			No ) exit;;
		esac
	done
fi

mkdir $DOSSIER 

cd $DOSSIER

echo "Télechargement de l'archive du SDK de QT $VERSIONQT"

wget -c $LIENQT

if [ -d "$ARCHIVEQT" ]; then
    echo "Erreur lors du téléchargement"
    exit
fi

echo "Archive : $ARCHIVEQT téléchargée"
echo "Décompression de l'archive"

tar xzvf $ARCHIVEQT > /dev/null

#if [ -d "$QT" ]; then
#    echo "Erreur lors de la décompression"
#    exit
#fi

echo "Archive décompressée"
echo "Suppression de l'archive : $ARCHIVEQT"

rm -r $ARCHIVEQT

echo "Téléchargement de l'archive du compilateur ARM"

wget -c $LIENARM

if [ -d $ARCHIVECOMPILATEUR ]; then
    echo "Erreur lors du téléchargement"
    exit
fi

echo "Archive : $ARCHIVECOMPILATEUR téléchargée"
echo "Décompression de l'archive"

tar xJf $ARCHIVECOMPILATEUR > /dev/null

#if [ -d $COMPILATEUR ]; then
#    echo "Erreur lors de la décompression"
#    exit
#fi

echo "Archive décompressée"
echo "Suppression de l'archive : $ARCHIVECOMPILATEUR"

echo "Test du compilateur téléchargé"

$COMPILATEUR/bin/arm-linux-gnueabihf-gcc --version > tmp.txt

if [ 'grep -Fxq "Copyright" tmp.txt' ]; then
    echo "Compilateur OK"
else
    echo "Erreur avec le compilateur"
    exit
fi

rm tmp.txt

echo "Modification de $QMAKECONF"

sed -i 's/\(.*QMAKE_CC.*\)/QMAKE_CC		= $HOMESED\/$DOSSIER\/$COMPILATEUR\/bin\/arm-linux-gnueabihf-gcc/g' $QMAKECONF
sed -i 's/\(.*QMAKE_CXX.*\)/QMAKE_CXX     = $HOMESED\/$DOSSIER\/$COMPILATEUR\/bin\/arm-linux-gnueabihf-g++/g' $QMAKECONF
sed -i 's/\(.*QMAKE_LINK.*\)/QMAKE_LINK     = $HOMESED\/$DOSSIER\/$COMPILATEUR\/bin\/arm-linux-gnueabihf-g++/g' $QMAKECONF
sed -i 's/\(.*QMAKE_LINK_SHLIB.*\)/QMAKE_LINK_SHLIB     = $HOMESED\/$DOSSIER\/$COMPILATEUR\/bin\/arm-linux-gnueabihf-g++/g' $QMAKECONF
sed -i 's/\(.*QMAKE_AR.*\)/QMAKE_AR     = $HOMESED\/$DOSSIER\/$COMPILATEUR\/bin\/arm-linux-gnueabihf-ar cqs/g' $QMAKECONF
sed -i 's/\(.*QMAKE_OBJCOPY.*\)/QMAKE_OBJCOPY     = $HOMESED\/$DOSSIER\/$COMPILATEUR\/bin\/arm-linux-gnueabihf-objcopy/g' $QMAKECONF
sed -i 's/\(.*QMAKE_STRIP.*\)/QMAKE_STRIP     = $HOMESED\/$DOSSIER\/$COMPILATEUR\/bin\/arm-linux-gnueabihf-strip/g' $QMAKECONF

echo "Lancement du script configure de QT"
echo "Installation de QT $VERSIONQT dans $REPERTOIRE"

cd $HOME/$DOSSIER/$QT

./configure -opensource -confirm-license -prefix $REPERTOIRE -embedded arm -little-endian -no-pch -xplatform qws/linux-arm-gnueabi-g++

echo "Lancement du make sur tous les coeurs de la machine"
echo "Il y a $COEUR coeurs"

COEUR=$(($COEUR+1))
make -j$COEUR ARCH=arm CROSS_COMPILE=$HOME/$DOSSIER/$COMPILATEUR/bin/arm-linux-gnueabihf-

echo "DONE IT WORKS BAWHAHA"
