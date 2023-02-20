## Challenge 1

To solve this one is necessary to change the procedure to get a single object instead the full list in the Mongo DB

Returning a find_one instead of a find if there is a proper id in the http request will make the deal:

```
return mongo.db.restaurant.find_one(query)
```

To return the 204 instead of an empty array when there are not matches with the provided identifier we can return the following:

```
    if restaurants is None:
        return ('', 204)
```

## Challenge 2

For this one, as the repository was already on github I decided to use github actions directly:
You can find the pipeline of the test in `.github/workflows`
I added a Lint check with flake8, as well as the tox checks


## Challenge 3

I added the dockerfile for the application, I decided to use Alpine python version for its lightweight:

```
FROM python:3.12.0a5-alpine3.17
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
EXPOSE 8080

```

## Challenge 4

To dockerize the database without having the necessity of hardcoding the credentials I decided to use env variables.
This is the Dockerfile:

```
FROM bitnami/mongodb:6.0-debian-11
COPY ./data /data/db

ARG MONGODB_ROOT_PASSWORD \
		MONGODB_ROOT_USER \
		MONGODB_USERNAME \
		MONGODB_PASSWORD \
		MONGODB_DATABASE
ENV MONGODB_ROOT_PASSWORD=$MONGODB_ROOT_PASSWORD \
		MONGODB_ROOT_USER=$MONGODB_ROOT_USER \
		MONGODB_USERNAME=$MONGODB_USERNAME \
		MONGODB_PASSWORD=$MONGODB_PASSWORD \
		MONGODB_DATABASE=$MONGODB_DATABASE
EXPOSE 27017
```

To launc it is portant to first set the environment variables, this is an example:

```
export MONGODB_ROOT_PASSWORD=root
export MONGODB_ROOT_USER=root
export MONGODB_USERNAME=mongodb
export MONGODB_PASSWORD=mongodb
export MONGODB_DATABASE=development
```
then build the image:

```
docker build -t gabourrutia/intelygenz-mongodb:latest . --build-arg MONGODB_ROOT_PASSWORD=$MONGODB_ROOT_PASSWORD --build-arg MONGODB_ROOT_USER=$MONGODB_ROOT_USER --build-arg MONGODB_USERNAME=$MONGODB_USERNAME --build-arg MONGODB_PASSWORD=$MONGODB_PASSWORD --build-arg  MONGODB_DATABASE=$MONGODB_DATABASE
```
I pushed both images to my personal repo just to have it for the kubernetes and docker-compose sets:

```
docker tag gabourrutia/intelygenz-flask:latest gabourrutia/intelygenz-flask:latest
docker push gabourrutia/intelygenz-flask:latest 

docker tag gabourrutia/intelygenz-mongodb:latest gabourrutia/intelygenz-mongodb:latest 
docker push gabourrutia/intelygenz-mongodb:latest
```

## Challenge 5

Docker-compose it!
you can find the docker-compose file in the root folder of the repo.

I added another container to make the curl request internally

Besides, also I added th MONGO_URI in a .env for passing it to the docker-compose, the process for loading the docker compose is:

```
source .env
docker-compose up
```

## Final Challenge

For this one I decided to use the images I released to dockerhub in both the deployment and the service resources. the code is in  `kubernetes` folder

to deployed we can:
```
microk8s enable host-access
microk8s kubectl apply -f .
microk8s kubectl get pods
```
## Issues I had

Unfortunately, I had no time to solve the issue of the initalization of the data and in the end I used this command:

```
mongoimport  --type json --collection restaurant --file restaurant.json --uri mongodb://mongodb:mongodb@mongo:27017/development
```
I know the way to solve it is either or execute the command at the starting point or from a sidecar container when the system starts but that's something I didn't have time to solve.

Besides, I know the best practize to persist the data is to mount the volume as a pvc and a vc in the deployment, but neither I have time to deployed
