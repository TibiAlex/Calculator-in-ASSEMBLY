section .data
    delim db " ", 0
    test: db "-234", 0
    ok dd 0
    minus dd 0
    num dd 0
    depth dd 0

section .bss
    root resd 1

section .text

extern strdup
extern strtok
extern strlen
extern check_atoi
extern print_tree_inorder
extern print_tree_preorder
extern evaluate_tree
extern calloc
extern malloc
extern atoi

global create_tree
global iocla_atoi

;;functia atoi implementata in limbajul assembly
iocla_atoi: 
    ; TODO
    ;;eliberam memoria variabilelor folosite
    xor ecx, ecx
    xor edx, edx
    xor eax, eax
    ;;initiem variabila pentru cazul in care numarul este negativ
    mov dword[minus], 0
    ;;luam sirul care urmeaza sa fie transformat
    mov ecx, [esp + 4]

;;incepem cu o structura de for sa parcurgem sirul 
for_atoi:
    cmp byte[ecx], 0
    je final_atoi
    
    ;;verificam daca numarul este negativ
    cmp byte[ecx], 45
    je negativ
    jmp pozitiv

;;daca este negativ variabila minus devine 1
negativ:
    mov dword[minus], 1
    inc ecx
    jmp for_atoi
    
;;daca caracterul nu este minus il adaugam in numar
pozitiv: 
    mov dl, byte[ecx]
    sub edx, 48
    mov dword[num], eax
    add eax, dword[num]
    add eax, dword[num]
    add eax, dword[num]
    add eax, dword[num]
    add eax, dword[num]
    add eax, dword[num]
    add eax, dword[num]
    add eax, dword[num]
    add eax, dword[num]
    add eax, edx
    
    ;;trecem la pasul urmator
    inc ecx
    jmp for_atoi
    
;;la final verificam daca variabila minus este 1
;;si facem numarul negativ
final_atoi:  
    cmp dword[minus], 1
    je cu_semn
    jmp ending
cu_semn:
    mov dword[num], eax
    sub eax, dword[num]
    sub eax, dword[num]    
ending: 
    xor ecx, ecx
    xor edx, edx   
    ret
    
;;functie pentru alocat memorie
;;folosesc functia calloc
alloc_mem:
    push dword 12
    push dword 1
    call calloc
    add esp, 8
    ret
    
;;label care face nodul root
;;gasim folosind strtok primul semn
;;alocam memorie lui *data folosind strdup
;;apoi punem sirul in nodul creat    
create_root:
    push delim
    push esi
    call strtok
    add esp, 8
    xor ecx, ecx
    mov ecx, eax
    push ecx
    call alloc_mem
    pop ecx
    mov edx, eax
    push edx
    push ecx
    call strdup
    add esp, 4
    pop edx
    mov [edx], eax
    jmp created_root
    
;;label care creaza un nou nod
;;aloca memorie sirului folosind strdup
;;si il punem in nod
new_node:
    push edx
    call alloc_mem
    pop edx
    mov ebx, eax
    push ebx
    push edx
    call strdup
    add esp, 4
    pop ebx
    mov [ebx], eax
    jmp created_node

;;functia pentru crearea arborelui
create_tree:
    ; TODO
    enter 0, 0
    xor eax, eax
    
    ;;punem registrii pe stiva pentru a nu pierde ce este in ei
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    ;;luam sirul din stiva
    mov esi, [ebp + 8]
   
    ;;cream root-ul
    jmp create_root
    
created_root:
    push edx
    push edx
    
    ;;stabilim variabilele pentru numere negative
    ;;si pentru adancimea arborelui
    mov dword[ok], 0
    mov dword[depth], 1

;;cu ajutorul unui for
;;facem strtok si luam fiecare semn si numar din sir    
for_strtok:
    push dword delim
    push dword 0
    call strtok
    add esp, 8
    cmp eax, 0
    je fin
    xor edx, edx
    xor ebx, ebx
    mov edx, eax
    
    ;;cream un nod nou la fiecare pas
    jmp new_node
    
created_node:
   
   ;;cu nodul creat verificam daca numarul are 
   ;;mai mult de 1 caracter pentru a prelucra numerele
   ;;negative (altfel calculatorul vede - ca semn)
   xor esi, esi 
   mov eax, ebx
   push eax
   xor eax, eax
   push edx
   call strlen
   pop edx
   mov dword[ok], eax
   pop eax
   cmp dword[ok], 1
   jg numar

   ;;verificam daca sirul este semn
   cmp byte[edx], 43
   je semn
   cmp byte[edx], 42
   je semn
   cmp byte[edx], 47
   je semn
   cmp byte[edx], 45
   je semn
   
   ;;daca nu este numar
   jmp numar
    
back:
    xor edx, edx
    xor ebx, ebx
    jmp for_strtok
    
fin:

;;eliberam memoria ramasa pe stiva
for_eliberare_stiva:
    cmp dword[depth], 0
    je stiva_goala
    
    add esp, 4
    
    dec dword[depth]
    jmp for_eliberare_stiva
stiva_goala:

    ;;punem in eax adresa primului nod
    pop eax
    
    ;;scoatem din stiva registrii salvati la inceput
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    
    leave
    ret
    
;;daca este semn luam untimul nod din stiva
;;verificam daca are noduri goale 
;;daca sunt punem fiul stang sau drept 
;;apoi il adaugam in stiva
semn:
    xor ecx, ecx
    xor esi, esi
    mov esi, edx
    pop edx
    mov ecx, [edx + 4]
    cmp ecx, 0
    je fiul_stang_semn
    xor ecx, ecx
    mov ecx, [edx + 8]
    cmp ecx, 0
    je fiul_drept_semn
    dec dword[depth]
    jmp semn
    jmp back
    
;;label pentru a pune un nod ca fiu stang
fiul_stang_semn:
    mov [edx + 4], ebx
    push edx
    push ebx
    inc dword[depth]
    jmp back
   
;;label pentru a pune un nod ca fiu drept
fiul_drept_semn:
    mov [edx + 8], ebx
    push edx
    push ebx
    inc dword[depth]
    jmp back
   
;;label pentru noduri ce contin numere   
;;luam ultimul nod din stiva
;;si verificam daca are toti fii
;;daca ii are luam urmatorul din stiva
;;daca nu ii are punem nodul curent ca fiu 
numar:
    xor ecx, ecx
    xor esi, esi
    mov esi, edx
    pop edx
    mov ecx, [edx + 4]
    cmp ecx, 0
    je fiul_stang
    xor ecx, ecx
    mov ecx, [edx + 8]
    cmp ecx, 0
    je fiul_drept
    dec dword[depth]
    jmp numar
    jmp back
 
;;label pentru a pune un nod ca fiu stang   
fiul_stang:
    mov [edx + 4], ebx
    push edx
    jmp back
   
;;label pentru a pune un nod ca fiu drept
fiul_drept:
    mov [edx + 8], ebx
    push edx
    pop edx
    dec dword[depth]
    jmp back
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
