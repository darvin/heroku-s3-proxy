#Static sites hosting

Stores uploaded files in MongoDB. Main purpose - allow to publish generated documentation no Heroku

## Usage
You can upload `.zip` file on main page or you can do that from command line

```
cat docs.zip |curl -F "siteName=MY_SITE_NAME" -F "archive=@-" http://static-sites-hosting.herokuapp.com:3000/publish/
```