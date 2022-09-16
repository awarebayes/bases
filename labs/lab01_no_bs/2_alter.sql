ALTER TABLE images
    ADD CONSTRAINT downloads CHECK (downloads >= 0);

ALTER TABLE images
    ADD CONSTRAINT image_size CHECK (image_size >= 0);

ALTER TABLE nodes
    ADD CONSTRAINT device_count CHECK (device_count >= 0);