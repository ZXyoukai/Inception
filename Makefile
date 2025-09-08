RUN = docker-compose.yml
SRCS = srcs

all:
	./ $(SRCS)$(RUN)
	
clean:

fclean:

re:

.PHONY: all clean fclean re
