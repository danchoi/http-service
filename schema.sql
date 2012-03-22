

create table urls (
  url varchar unique
);
create table crawls (
  crawl_id serial primary key,
  created timestamp with time zone default now(),
  started timestamp with time zone,
  completed timestamp with time zone,
  url_count integer default 0,
  success_count integer default 0,
  urls text,
  callback_url varchar
);

create table requests (
  request_id serial primary key,
  crawl_id integer not null references crawls,
  url varchar references urls(url),
  redirect varchar,
  response_code integer,
  content_type varchar,
  headers text,
  body text,
  latency float,
  error text,
  created timestamp with time zone default now()
);

