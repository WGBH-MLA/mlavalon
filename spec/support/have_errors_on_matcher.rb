# Matcher for models using ActiveModel::Validations.
# Usage:
#   it 'has errors on :foo and :bar, but not on :biz nor :baz, after running validations' do
#     subject.validate
#     expect(subject).to have_errors_on :foo, :bar
#     expect(subject).not_to have_errors_on :biz, :baz
#   end
RSpec::Matchers.define :have_errors_on do |*fields|
  match do |model|
    raise ArgumentError, "have_errors_on expects #{model} to implement ActiveModel::Valdiations" unless model.is_a? ActiveModel::Validations
    # Return true if all the fields passed in have errors.
    (fields - model.errors.keys).empty?
  end

  failure_message do |model|
    fields_missing_errors = fields - model.errors.keys
    "expected #{model.class} instance to have at least one error on " \
    ":#{fields_missing_errors.join(', :')} but none were found."
  end

  failure_message_when_negated do |model|
    unexpected_errors = model.errors.select do |error|
      # `error` is an array, where the first element is the field name.
      fields.include? error.first
    end
    error_msgs = unexpected_errors.each_with_index.map do |error, i|
      "#{i+1} - #{error[0]}: #{error[1]}"
    end
    "Unexpected errors on #{model.class}: " \
    "\n\t#{ error_msgs.join("\n\t") }"
  end
end

# Matcher for models using ActiveModel::Validations.
# Usage:
#   it 'has an error on :foo with message "Foo is wrong"
#     subject.validate
#     expect(subject).to have_errors_on :foo, "Foo is wrong"
#     # or with regex
#     expect(subject).to have_errors_on :foo, /wrong/
#   end
RSpec::Matchers.define :have_error_on do |field, msg=nil|
  match do |model|
    raise ArgumentError, "have_error_on expects #{model} to implement ActiveModel::Valdiations" unless model.is_a? ActiveModel::Validations
    # Return true there is an error on the given field...
    pass = model.errors.key? field
    if msg
      if msg.is_a? String
        pass &= model.errors[field] == msg
      elsif msg.is_a? Regexp
        pass &= !model.errors[field].grep(msg).empty?
      else
        raise ArgumentError, "have_error_on expect the second argument to be a String or Regexp, but #{msg.class} was given."
      end
    end
    pass
  end

  failure_message do |model|
    if !model.errors.key?(field)
      "expected #{model.class} instance to have an error on :#{field}, but " +
      "none were found."
    else
      "expected #{model.class} instance to have an error on :#{field} with a " +
      "message matching '#{msg}', but the message was '#{model.errors[field]}'."
    end
  end

  failure_message_when_negated do |model|
    if !model.errors.key?(field)
      "expected #{model.class} instance not to have an error on :#{field}, but " +
      "found error '#{model.errors[field]}'."
    else
      "expected #{model.class} instance not to have an error on :#{field} with a " +
      "message matching '#{msg}', but one was found."
    end
  end
end
