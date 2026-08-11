# Temporary database layer
#
# For now, we are using a Python list as temporary storage.
# Later, this file will be replaced/extended to connect
# to the real PostgreSQL database.


tickets = []


next_ticket_id = 1


def get_next_ticket_id():
    global next_ticket_id

    ticket_id = next_ticket_id
    next_ticket_id += 1

    return ticket_id

