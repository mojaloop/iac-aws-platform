length = ${password_length}
rule "charset" {
charset = "abcdefghijklmnopqrstuvwxyz"
min-chars = 1
}
rule "charset" {
charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
min-chars = 1
}
rule "charset" {
charset = "0123456789"
min-chars = 1
}
%{ if use_special_chars ~}
rule "charset" {
charset = "${special_char_list}"
min-chars = 1
}
%{ endif ~}