-- This script gives access to information about records
-- independently of current savegames.

local records_manager = {}

local records = {}

-- Loads and returns a table of quest records with the following optional keys:
-- - rank_100_percent (boolean): Whether 100% of the quest were completed.
-- - rank_ultimate (boolean): Whether the ultimate rank was obtained, that is,
--   finishing the game without dying, with 10 hearts maximum, without talking
--   to great fairies, without buying bottles and without taking the shield.
-- - rank_speed (boolean): Whether the quest was completed in less than 2 hours.
-- - best_time (integer): Best time to complete the quest, in seconds.
function records_manager:load()

  local file = sol.file.open("records.dat")
  if file == nil then 
    return
  end

  records.rank_100_percent = file:read("*n") == 1
  records.rank_ultimate = file:read("*n") == 1
  records.rank_speed = file:read("*n") == 1
  local best_time = file:read("*n")
  if best_time == 0 then
    records.best_time = nil
  else
    records.best_time = best_time
  end

  return records
end

-- Saves the records into their file.
function records_manager:save()

  local file, error_message = sol.file.open("records.dat", "w")
  if file == nil then
    error("Cannot save records file: " .. error_message)
  end

  file:write(records.rank_100_percent and 1 or 0)
  file:write(" ")
  file:write(records.rank_ultimate and 1 or 0)
  file:write(" ")
  file:write(records.rank_speed and 1 or 0)
  file:write(" ")
  file:write(records.best_time or 0)
  file:write(" ")

  file:close()
end

function records_manager:clear()
  records = {}
end

function records_manager:get_rank_100_percent()
  return records.rank_100_percent
end

function records_manager:set_rank_100_percent()
  records.rank_100_percent = true
end

function records_manager:get_rank_ultimate()
  return records.rank_ultimate
end

function records_manager:set_rank_ultimate()
  records.rank_ultimate = true
end

function records_manager:get_rank_speed()
  return records.rank_speed
end

function records_manager:set_rank_speed()
  records.rank_speed = true
end

function records_manager:get_best_time()
  return records.best_time
end

function records_manager:get_best_time_text()

  local best_time = records_manager:get_best_time()
  if best_time == nil then
    return ""
  end

  local total_seconds = best_time
  local seconds = total_seconds % 60
  local total_minutes = math.floor(total_seconds / 60)
  local minutes = total_minutes % 60
  local total_hours = math.floor(total_minutes / 60)
  local time_string = string.format("%02d:%02d:%02d", total_hours, minutes, seconds)
  return time_string
end

-- Indicates that the quest was completed with the specified time in seconds.
-- If it is faster than the best one, it replaces it.
function records_manager:add_candidate_time(time)

  if records.best_time == nil or time < records.best_time then
    records.best_time = time
  end
end

return records_manager