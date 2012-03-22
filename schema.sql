

create table urls (
  url varchar unique
);

create table requests (
  request_id serial primary key,
  url varchar references urls(url),
  redirect varchar references urls(url),
  content_type varchar,
  headers text,
  body text,
  latency float,
  error text,
  created timestamp with time zone default now()
);
