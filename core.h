#ifndef CORE_H
#define CORE_H

#include <QtCore>//для доступа к qApp


class Core : public QObject
{
    Q_OBJECT
public:
    explicit Core(QObject *parent = nullptr);

public slots:
    void slotQuit();

};

#endif // CORE_H
