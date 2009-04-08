$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.dirname(__FILE__))

module Wowr
	module Classes
		class CommonCalendar
			attr_reader		      :summary, :calendar_type, :start, :icon

			def initialize(json, api = nil)
				@summary	  = json["summary"]
				@calendar_type    = json["calendarType"]
				@start            = Time.at((json["start"] / 1000).floor)
				@icon             = json["icon"]
			end
		end

		class WorldCalendar < CommonCalendar
			attr_reader		      :end, :description, :priority

			def initialize(json, api = nil)
				super(json, api)
				@end              = Time.at((json["end"] / 1000).floor)
				@description      = json["description"]
				@priority         = json["priority"]
			end
		end

		class UserCommonCalendar < CommonCalendar
			attr_reader		      :type, :owner, :moderator, :id

			def initialize(json, api = nil)
				super(json, api)
				@type             = json["type"]
				@owner            = json["owner"]
				@moderator        = json["moderator"] if json["moderator"]
				@id               = json["id"]
			end
		end

		class UserCalendar < UserCommonCalendar
			attr_reader		      :inviter, :status

			def initialize(json, api = nil)
				super(json, api)
				@inviter          = json["inviter"]
				@status           = json["status"]
			end
		end

		class UserDetailCalendar < UserCommonCalendar
			attr_reader		      :locked, :description, :invites

			def initialize(json, api = nil)
				super(json, api)
				@locked           = json["locked"]
				@description      = json["description"]

				@invites = []

				json["invites"].each do |invitee|
					@invites << UserDetailInvitee.new(invitee, api)
				end
			end
		end

		class UserDetailInvitee
			attr_reader		      :class_id, :status, :moderator, :invitee, :id

			def initialize(json, api = nil)
				@class_id         = json["class_id"]
				@status           = json["status"]
				@moderator        = json["moderator"]
				@invitee          = json["invitee"]
				@id               = json["id"]
			end
		end
	end
end
