#include <mysql/mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void finish_with_error(MYSQL *con) {
    fprintf(stderr, "%s\n", mysql_error(con));
    mysql_close(con);
    exit(1);
}

int verify_user(MYSQL *con, const char *name, int room_number, int bed_number) {
    char query[256];
    sprintf(query, "SELECT * FROM Students WHERE name='%s' AND room_number=%d AND bed_number=%d", name, room_number, bed_number);

    if (mysql_query(con, query)) {
        finish_with_error(con);
    }

    MYSQL_RES *result = mysql_store_result(con);
    if (result == NULL) {
        finish_with_error(con);
    }

    int num_rows = mysql_num_rows(result);
    mysql_free_result(result);

    return num_rows > 0;
}

void show_available_slots(MYSQL *con, int stall_id, const char *booking_date) {
    char query[256];
    sprintf(query, "SELECT t.time_slot, IF(b.booking_id IS NULL, 'Available', 'Booked') AS status "
                   "FROM TimeSlots t "
                   "LEFT JOIN Bookings b ON t.time_slot = b.time_slot AND b.booking_date = '%s' AND b.stall_id = %d "
                   "ORDER BY t.time_slot", booking_date, stall_id);

    if (mysql_query(con, query)) {
        finish_with_error(con);
    }

    MYSQL_RES *result = mysql_store_result(con);
    if (result == NULL) {
        finish_with_error(con);
    }

    printf("Available Time Slots for Stall %d on %s:\n", stall_id, booking_date);
    MYSQL_ROW row;
    while ((row = mysql_fetch_row(result))) {
        printf("Time Slot: %s - %s\n", row[0], row[1]);
    }
    mysql_free_result(result);
}

void book_slot(MYSQL *con, int room_number, int bed_number, int stall_id, const char *booking_date, const char *time_slot) {
    char query[512];
    sprintf(query, "INSERT INTO Bookings (room_number, bed_number, stall_id, booking_date, time_slot) "
                   "VALUES (%d, %d, %d, '%s', '%s')", room_number, bed_number, stall_id, booking_date, time_slot);

    if (mysql_query(con, query)) {
        fprintf(stderr, "Booking failed: %s\n", mysql_error(con));
    } else {
        printf("Booking successful for %s at %s on %s\n", time_slot, booking_date, stall_id);
    }
}

int main() {
    MYSQL *con = mysql_init(NULL);
    if (con == NULL) {
        fprintf(stderr, "mysql_init() failed\n");
        exit(1);
    }

    if (mysql_real_connect(con, "localhost", "user", "password", "sandbox_db", 0, NULL, 0) == NULL) {
        finish_with_error(con);
    }

    char name[50];
    int room_number, bed_number, stall_id;
    char booking_date[11];
    char time_slot[9];

    printf("Enter your name: ");
    scanf("%49s", name);
    printf("Enter your room number: ");
    scanf("%d", &room_number);
    printf("Enter your bed number: ");
    scanf("%d", &bed_number);

    if (!verify_user(con, name, room_number, bed_number)) {
        printf("Verification failed. Access denied.\n");
        mysql_close(con);
        exit(0);
    }

    printf("Verification successful!\n");

    printf("Enter the stall ID you want to book: ");
    scanf("%d", &stall_id);
    printf("Enter the booking date (YYYY-MM-DD): ");
    scanf("%10s", booking_date);

    show_available_slots(con, stall_id, booking_date);

    printf("Enter the time slot you want to book (HH:MM:SS): ");
    scanf("%8s", time_slot);

    book_slot(con, room_number, bed_number, stall_id, booking_date, time_slot);

    mysql_close(con);
    return 0;
}
