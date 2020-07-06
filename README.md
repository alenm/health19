## About Health19
This is a website that takes the data from [Johns Hopkins University Center for Systems Science and Engineering](https://github.com/CSSEGISandData/COVID-19)
and presents it in a visualized way. 

![health19-video](https://user-images.githubusercontent.com/568130/85213210-43c16400-b329-11ea-8205-6da0da584e24.gif)
![health19-02](https://user-images.githubusercontent.com/568130/85213200-25f3ff00-b329-11ea-9319-6f342d620def.png)
![health19-03](https://user-images.githubusercontent.com/568130/85213201-268c9580-b329-11ea-87a2-93adadce6ae6.png)
![health19-04](https://user-images.githubusercontent.com/568130/85213202-268c9580-b329-11ea-8838-69ba78f2214e.png)

## Project Goals
* URL for regions and continents. Makes it easy to quickly narrow my research.
* Show only the last 14 days.
* Show the data in a heatmap table, with other visual layouts.
* Make it open source so others can learn how [Phoenix](https://www.phoenixframework.org) / [Elixir](https://elixir-lang.org) and [Postgres](https://www.postgresql.org) work.

## NOTE
All data comes from this Johns Hopkins University Github Repo. I am not affiliated with the Johns Hopkins University. I'm just taking the data and building an interface around it.

## CSV and Scrubbing
I parse the CSV data from [Johns Hopkins University Center for Systems Science and Engineering](https://github.com/CSSEGISandData/COVID-19)
nd then I add additional information to the CSV such as `iso_code`, `continent_iso_code` and better labels for the country names. 

By adding additonal information, I find navigating through the site easier.

## Installation
You need to have Elixir, Phoenix and Postgres running on your local system

To start your Phoenix server:

  * `cd` into the project
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Once that is completed and you have the database setup. You can run the following `mix task` from the directory.

`mix health.seeder`

This task will take the data from `priv/repo/seed_data.sql` and import it into your database. If everything works out you should have the latest data as of July 5, 2020. I will make updates once in awhile with the latest data so then all you have to do is run this task.

## Details About App
* Flag icons are from [FamFam](http://www.famfamfam.com/lab/icons/flags/)
* Framework is [Phoenix](https://www.phoenixframework.org) / [Elixir](https://elixir-lang.org), Database is [Postgres](https://www.postgresql.org).
