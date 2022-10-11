extern "C" void main() {

    // This is the function i.e. called after our bootloader switches to PM.
 
    *(char*)0xb8000 = 'H';
    *(char*)0xb8002 = 'e';
    *(char*)0xb8004 = 'l';
    *(char*)0xb8006 = 'l';
    *(char*)0xb8008 = 'o';
    *(char*)0xb800a = ' ';
    *(char*)0xb800c = 'm';
    *(char*)0xb800e = 'o';
    *(char*)0xb8010 = 'm';
    *(char*)0xb8012 = 'o';
    *(char*)0xb8014 = '!';

    return;
}
