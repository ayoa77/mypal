class CustomLogger
	def self.add( filename, method, parameters, error = nil )

    entry = { file: filename, method: method }.merge(parameters)
    # entry = entry.merge(error: error) if error.present?

    Log.add(entry)

    if error.present?
      ExceptionNotifier.notify_exception(error)
    end
	end
end
