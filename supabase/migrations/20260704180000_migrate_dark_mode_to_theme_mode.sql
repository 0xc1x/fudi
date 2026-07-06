-- Migration: Change dark_mode (boolean) to theme_mode (text) in user_preferences

-- 1. Add new column with default value 'system'
alter table public.user_preferences add column theme_mode text not null default 'system';

-- 2. Populate the theme_mode column based on the existing dark_mode value
update public.user_preferences
set theme_mode = case 
  when dark_mode = true then 'dark'
  else 'light'
end;

-- 3. Drop the old dark_mode column
alter table public.user_preferences drop column dark_mode;
