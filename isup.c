#include <errno.h>
#include <fcntl.h>
#include <stdio.h> /* TODO remove */
#include <string.h>
#include <unistd.h>

enum {
	PATHLEN = 1024
};

int
is_up(char *srv_path)
{
	char in_path[PATHLEN + 1] = {0};
	int fd;
	int ret;

	strncat(in_path, srv_path, PATHLEN - 3); /* TODO do in ada? */
	strncat(in_path, "/in", 3);

	errno = 0;
	fd = open(in_path, O_WRONLY | O_NONBLOCK);
	/* TODO test if fifo or regular file etc */
	if (!errno) {
		ret = 1; /* fifo is up */
	} else if (errno == ENXIO) {
		ret = 0; /* fifo is down */
	} else if (errno) {
		fprintf(stderr, "error opening file\n");
		ret = 1; /* pretend it's up to deter tampering */
		/* TODO ada exceptions */
	}

	close (fd);
	return ret;
}
