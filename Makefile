FRAMEBUFFER_COMMIT=1f31c0c79fac74344c0eaca37b02f9a3cf6dca10
FUSE_URL=https://ftp.halifax.rwth-aachen.de/debian/pool/main/f/fuse/fuse_2.9.9-1+deb10u1_armhf.deb
FUSE_FILENAME=fuse_2.9.9-1+deb10u1_armhf.deb
FUSE_CHECKSUM=610b19c800bd7624b19b34de8eb2030c4596a64b2ce6f9efe074d844e3fb798b

.DEFAULT: dist

.PHONY: cryptodaemon gocryptfs password_prompt print framebuffer dist dist_tar

dist: cryptodaemon dist/home/crypto/bin/fusermount gocryptfs password_prompt print framebuffer

dist_go: cryptodaemon gocryptfs

dist_qt: password_prompt print framebuffer

dist_rest: dist/home/crypto/bin/fusermount

cryptodaemon:
	GOARCH=arm CGO_ENABLED=0 go build -o dist/home/crypto/bin/cryptodaemon ./cryptodaemon

dist/home/crypto/bin/fusermount: Makefile
	wget ${FUSE_URL} -O ${FUSE_FILENAME}
	echo "${FUSE_CHECKSUM} ${FUSE_FILENAME}" | sha256sum -c || (echo "Fuse Package Checksum Mismatch" && rm ${FUSE_FILENAME} && exit 1)
	ar -p ${FUSE_FILENAME} data.tar.xz | tar --to-stdout -Jx ./bin/fusermount > ./dist/home/crypto/bin/fusermount
	rm ${FUSE_FILENAME}
	chmod +x ./dist/home/crypto/bin/fusermount

dist_tar: dist
	tar cvzf remarkable-crypto-files.tar.gz -C ./dist .

gocryptfs:
	GOARCH=arm CGO_ENABLED=0 go build -tags without_openssl -o dist/home/crypto/bin/gocryptfs "github.com/rfjakob/gocryptfs"

password_prompt:
	cd gui/password_prompt && qmake && make && mv password_prompt ../../dist/home/crypto/bin/password_prompt

print:
	cd gui/print && qmake && make && mv print ../../dist/home/crypto/bin/print

framebuffer:
	mkdir -p ./dist/home/crypto/lib
	[ -d "remarkable2-framebuffer" ] || git clone https://github.com/ddvk/remarkable2-framebuffer.git
	cd remarkable2-framebuffer && git checkout ${FRAMEBUFFER_COMMIT}
	cd remarkable2-framebuffer && git reset --hard && git apply ../framebuffer.patch # remove this when https://github.com/ddvk/remarkable2-framebuffer/pull/120 is merged
	cd remarkable2-framebuffer && qmake && make
	arm-linux-gnueabihf-strip remarkable2-framebuffer/src/client/librm2fb_client.so.1.0.1
	cp remarkable2-framebuffer/src/client/librm2fb_client.so.1.0.1 dist/home/crypto/lib/librm2fb_client.so
	cp remarkable2-framebuffer/src/server/librm2fb_server.so.1.0.1 dist/home/crypto/lib/librm2fb_server.so

clean:
	git clean -f -X dist
	rm -rf remarkable2-framebuffer
	cd gui/password_prompt && make clean
	cd gui/print && make clean
