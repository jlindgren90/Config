pkgname=config
pkgver=0.1
pkgrel=1
arch=('x86_64')
depends=()

package() {
    cd ..
    make DESTDIR="${pkgdir}" install-system
}
