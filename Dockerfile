# Stage 1 : Budowanie
FROM ubuntu:24.04 AS builder

# Instalacja kompilatora g++, cmake i bibliotekę asio wymaganej przez crow
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    libasio-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

# Kopiowanie repozytorium
COPY . .

# Konfiguracja i kompilacja (nie ma potrzeby używać kompresji danych, instalacji zlib ani certyfikatów ssl)
RUN cmake . -DCROW_BUILD_TESTS=OFF -DCROW_BUILD_EXAMPLES=ON -DCROW_ENABLE_COMPRESSION=OFF -DCROW_ENABLE_SSL=OFF && make helloworld

# Stage 2 : Uruchamianie obrazu produkcyjnego - mały obraz bez zbędnych zależności
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Kopiowanie pliku binarnego ze struktury buildera
COPY --from=builder /usr/src/app/examples/helloworld .

# Crow domyślnie nasłuchuje na porcie 18080
# http://localhost:18080/
EXPOSE 18080

# Uruchomienie aplikacji
CMD ["./helloworld"]
