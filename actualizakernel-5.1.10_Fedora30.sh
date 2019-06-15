#!/bin/bash
#Autor: Oscar A. Velasco Navarro
#Fecha: Domingo 15 de Junio de 2019
#Actualiza el Kernel en Fedora 30 de alguna versión anterior a la 5.1.10
#Fuente: https://www.cyberciti.biz/tips/compiling-linux-kernel-26.html
#Fuente: https://www.kernel.org/category/signatures.html

#Obtener el Kernel mas reciente desde el codigo fuente.
curl -OL https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-5.1.10.tar.xz

#Descargar la firma PGP
curl -OL https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-5.1.10.tar.sign

#Extrar el archivo.
unxz -v linux-5.1.10.tar.xz

#Verificar la firma
gpg2 --locate-keys torvalds@kernel.org gregkh@kernel.org

#Aparecera algo como esto:
#gpg: assuming signed data in 'linux-5.1.10.tar'
#gpg: Signature made Sun 09 Jun 2019 02:17:08 AM CDT
#gpg:                using RSA key 647F28654894E3BD457199BE38DBBDC86092693E
#gpg: Can't check signature: No public key

#  Developer 				  Fingerprint
#Linus Torvalds 	ABAF 11C6 5A29 70B1 30AB  E3C4 79BE 3E43 0041 1886
#Greg Kroah-Hartman 	647F 2865 4894 E3BD 4571  99BE 38DB BDC8 6092 693E

#Grabar la firma obtenida.
#gpg --recv-keys 647F28654894E3BD457199BE38DBBDC86092693E

#Verificamos nuevamente la firma con el comando gpg.
#gpg --verify linux-5.1.10.tar.sign
gpg2 --trust-model tofu --verify linux-5.1.10.tar.sign

#Aparecera algo como esto:
#gpg: assuming signed data in 'linux-5.1.10.tar'
#gpg: Signature made Sun 09 Jun 2019 02:17:08 AM CDT
#gpg:                using RSA key 647F28654894E3BD457199BE38DBBDC86092693E
#gpg: Good signature from "Greg Kroah-Hartman <gregkh@linuxfoundation.org>" [unknown]
#gpg:                 aka "Greg Kroah-Hartman <gregkh@kernel.org>" [unknown]
#gpg:                 aka "Greg Kroah-Hartman (Linux kernel stable release signing key) <greg@kroah.com>" [unknown]
#gpg: WARNING: This key is not certified with a trusted signature!
#gpg:          There is no indication that the signature belongs to the owner.
#Primary key fingerprint: 647F 2865 4894 E3BD 4571  99BE 38DB BDC8 6092 693E

#Sí en la salida del mensaje que se ejecuto con el comando "gpg -verify" no se produce "BAD SIGNATURE",
#procedemos a descomprimir el archivo usando el comado tar y damos enter.  
tar xvf linux-5.1.10.tar

#Cambiamos de directorio.
cd linux-5.1.10

#Hacemos copia del kernel actual.
cp -v /boot/config-$(uname -r) .config

#Ejemplo que se muestra a la salida 
#/boot/config-5.1.6-300.fc30.x86_64' -> '.config'

#Instalamos las herramientas de desarrollo necesarias para compilar el kernel.
dnf group install "Development Tools"
dnf install ncurses-devel bison flex elfutils-libelf-devel openssl-devel

#OJO Este paso es opcional, es para hacer modificaciones en el kernel.
#make menuconfig
#make xconfig  
#make gconfig

#Comienza a compilar y a crear una imagen comprimida del kernel
#La contrucción y compilación del kernel toman un tiempo 
#considerable así qué sé paciente durante este proceso.
make

#Instalar los módulos del kernel.
sudo make modules_install

#Instalar el kernel.
sudo make install

#Actuliza el grub.
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo grubby --set-default /boot/vmlinuz-5.1.10

#reiniciar.
reboot
