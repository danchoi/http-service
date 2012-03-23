

create table urls (
  url_id serial primary key,
  url varchar unique,
  last_body text
);

create table crawls (
  crawl_id serial primary key,
  created timestamp with time zone default now(),
  started timestamp with time zone,
  completed timestamp with time zone,
  url_count integer default 0,
  completed_count integer default 0,
  used_cached_count integer default 0, -- just use last recent result
  urls text,
  callback_url varchar,
  callback_completed timestamp with time zone
);

create table requests (
  request_id serial primary key,
  crawl_id integer not null references crawls,
  url varchar references urls(url),
  redirect varchar,
  response_code integer,
  content_type varchar,
  headers text,
  latency float,
  error text,
  created timestamp with time zone default now()
);

alter table urls add column last_request_id integer references requests(request_id);

