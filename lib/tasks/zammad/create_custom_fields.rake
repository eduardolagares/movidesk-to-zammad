
namespace :zammad do
    task :create_custom_fields do
        
        success_field1, result_field1 = Zammad::ObjectAttribute.create({
            name: ENV["ZAMMAD_MOVIDEKS_ID_FIELD_NAME"],
            object: "Ticket",
            display: "MOVIDESK ID",
            active: true,
            data_type: "input",
            data_option: {
                type: "text",
                maxlength: 100
            },
            editable: false,
            screens:{
                "create":{
                  "Customer":{
                    "shown":true,
                  }
                },
                "edit":{
                  "Customer":{
                    "shown":true
                  },
                  "Agent":{
                    "shown":true
                  }
                },
                "create_middle":{
                  "Agent":{
                    "shown":true
                  }
                }
            }
        })

        raise "Não foi possível criar o campo #{ENV["ZAMMAD_MOVIDEKS_ID_FIELD_NAME"]} para o objeto Ticket. #{result_field1.inspect}" unless success_field1

        success_field2, result_field2 = Zammad::ObjectAttribute.create({
            name: ENV["ZAMMAD_MOVIDEKS_ID_FIELD_NAME"],
            object: "User",
            display: "MOVIDESK ID",
            active: true,
            data_type: "input",
            data_option: {
                type: "text",
                maxlength: 100
            },
            screens:{
                "create":{
                  "Customer":{
                    "shown":true,
                  },
                  "Agent":{
                    "shown":true
                  },
                  "User": {
                      "shown":true
                  }
                },
                "view": {
                    "Customer":{
                        "shown":true,
                    },
                    "Agent":{
                        "shown":true
                    },
                    "User": {
                        "shown":true
                    }
                },
                "edit":{
                  "Customer":{
                    "shown":true
                  },
                  "Agent":{
                    "shown":true
                  },
                  "User": {
                    "shown":true
                    }
                }
            }
        })

        raise "Não foi possível criar o campo #{ENV["ZAMMAD_MOVIDEKS_ID_FIELD_NAME"]} para o objeto Ticket" unless success_field2


    end
end

