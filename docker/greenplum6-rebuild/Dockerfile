FROM treasuremaster/greenplum:6.27.1-oraclelinux8

COPY --chmod=750 --chown=${GREENPLUM_USER}:${GREENPLUM_GROUP} files/*.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/start_gpdb.sh"]
