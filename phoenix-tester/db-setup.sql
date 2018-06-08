
-- Setup script for phoenix test to be used by base mysql image

-- Create the test user
CREATE USER 'wf-user'@'%' IDENTIFIED BY 'wfpwd';
-- Grant full priviliges so that the ruby script can populate the database
GRANT ALL ON *.* to 'wf-user'@'%';