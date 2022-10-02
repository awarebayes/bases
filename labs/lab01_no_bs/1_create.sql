CREATE TABLE IF NOT EXISTS images
(
    id INT NOT NULL PRIMARY KEY,
    owner VARCHAR(128),
    image_name VARCHAR(128),
    downloads INT, -- CHECK(downloads >= 0),
    need_device BOOLEAN,
    image_size FLOAT, -- CHECK(image_size > 0),
    docker_version VARCHAR(128),
    runtime VARCHAR(128)
);

CREATE TABLE IF NOT EXISTS task_statuses
(
    id INT NOT NULL PRIMARY KEY,
    status VARCHAR(128)
);

ALTER TABLE task_statuses
ALTER COLUMN status TYPE VARCHAR(100);

CREATE TABLE IF NOT EXISTS nodes
(
    id INT NOT NULL PRIMARY KEY,
    ip VARCHAR(32) NOT NULL,
    device_count INT, -- CHECK(device_count >= 0)
    ram REAL
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
    FOREIGN KEY (dispatcher_id) REFERENCES dispatchers(id),

    time_created TIMESTAMP
);

CREATE TABLE IF NOT EXISTS volumes
(
    id INT NOT NULL PRIMARY KEY,

    task_id INT,
    FOREIGN KEY (task_id) REFERENCES tasks(id),

    host_path VARCHAR(512),
    container_path VARCHAR(128)
);