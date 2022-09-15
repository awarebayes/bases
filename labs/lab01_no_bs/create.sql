CREATE TABLE IF NOT EXISTS images
(
    id INT NOT NULL PRIMARY KEY,
    owner VARCHAR(128),
    image_name VARCHAR(128),
    downloads INT CHECK(downloads >= 0),
    need_device BOOLEAN,
    image_size FLOAT CHECK(image_size > 0),
    docker_version VARCHAR(128),
    runtime VARCHAR(128)
);

CREATE TABLE IF NOT EXISTS task_statuses
(
    id INT NOT NULL PRIMARY KEY,
    status VARCHAR(128)
);

CREATE TABLE IF NOT EXISTS nodes
(
    id INT NOT NULL PRIMARY KEY,
    ip VARCHAR(32),
    device_count INT CHECK(device_count >= 0)
);

CREATE TABLE IF NOT EXISTS dispatchers
(
    id INT NOT NULL PRIMARY KEY,
    name VARCHAR(128),
    email VARCHAR(128),
    mattermost VARCHAR(128)
    
);

CREATE  TABLE IF NOT EXISTS tasks
(
    id INT NOT NULL PRIMARY KEY,
    name VARCHAR(128),
    project VARCHAR(128),

    -- FK
    node_id INT,
    FOREIGN KEY (node_id) REFERENCES nodes(id),

    -- FK
    image_id INT,
    FOREIGN KEY (image_id) REFERENCES images(id),

    need_cuda BOOLEAN,

    -- FK
    status_id INT,
    FOREIGN KEY (status_id) REFERENCES task_statuses(id),

    -- FK
    dispatcher_id INT,
    FOREIGN KEY (dispatcher_id) REFERENCES dispatchers(id)
);

COPY images(id, owner, image_name, downloads, need_device, image_size, docker_version, runtime)
FROM '/home/dev/Documents/programming/uni/bases/labs/lab01_no_bs/res/Image.csv'
DELIMITER ','
CSV HEADER;

select * from images;
