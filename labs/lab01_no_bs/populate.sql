COPY images(id, owner, image_name, downloads, need_device, image_size, docker_version, runtime)
FROM '/home/dev/Documents/programming/uni/bases/labs/lab01_no_bs/res/Image.csv'
DELIMITER ','
CSV HEADER;

COPY images(id, owner, image_name, downloads, need_device, image_size, docker_version, runtime)
FROM '/home/dev/Documents/programming/uni/bases/labs/lab01_no_bs/res/Image.csv'
DELIMITER ','
CSV HEADER;
